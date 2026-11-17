-- ============================================================================
-- MATERNAL HEALTH PLATFORM - SERVER-SIDE RISK ENGINE & CLOSED LOOP LOGIC
-- Implements Section 6 & 7 of the Implementation Plan in PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SERVER-SIDE RISK ENGINE FUNCTION
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.calculate_patient_risk(p_patient_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_patient RECORD;
    v_latest_visit RECORD;
    v_prev_visit RECORD;
    v_missed_days INT := 0;
    v_score INT := 0;
    v_level TEXT := 'low';
    v_is_immediate_danger BOOLEAN := false;
    v_reasons TEXT[] := ARRAY[]::TEXT[];
    v_age INT;
    v_obstetric_points INT := 0;
BEGIN
    -- Fetch patient details
    SELECT * INTO v_patient FROM public.patients WHERE id = p_patient_id;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Patient not found');
    END IF;

    -- Calculate age
    v_age := DATE_PART('year', AGE(v_patient.date_of_birth));

    -- Fetch latest two visits for vitals & trends
    SELECT * INTO v_latest_visit FROM public.visits 
    WHERE patient_id = p_patient_id ORDER BY visit_date DESC, recorded_at DESC LIMIT 1;

    SELECT * INTO v_prev_visit FROM public.visits 
    WHERE patient_id = p_patient_id AND id != v_latest_visit.id 
    ORDER BY visit_date DESC, recorded_at DESC LIMIT 1;

    -- Count consecutive missed medicine days up to yesterday
    WITH recent_dates AS (
        SELECT (CURRENT_DATE - i)::DATE AS check_date
        FROM generate_series(1, 14) AS i
    ),
    daily_status AS (
        SELECT 
            rd.check_date,
            BOOL_OR(COALESCE(ml.taken, false)) AS any_taken
        FROM recent_dates rd
        LEFT JOIN public.medicine_logs ml 
            ON ml.patient_id = p_patient_id AND ml.log_date = rd.check_date
        GROUP BY rd.check_date
        ORDER BY rd.check_date DESC
    )
    SELECT COUNT(*) INTO v_missed_days
    FROM (
        SELECT check_date, any_taken,
               SUM(CASE WHEN any_taken THEN 1 ELSE 0 END) OVER (ORDER BY check_date DESC) as grp
        FROM daily_status
    ) t
    WHERE grp = 0;

    -- ──────────────────────────────────────────────────────────────────────────
    -- STEP 1: Danger Signs & Critical Values (Immediate HIGH)
    -- ──────────────────────────────────────────────────────────────────────────
    IF v_latest_visit.hemoglobin IS NOT NULL AND v_latest_visit.hemoglobin < 7.0 THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Severe Anemia (Hb ' || v_latest_visit.hemoglobin || ' g/dL < 7.0)');
    END IF;

    IF (v_latest_visit.systolic IS NOT NULL AND v_latest_visit.systolic >= 160) OR 
       (v_latest_visit.diastolic IS NOT NULL AND v_latest_visit.diastolic >= 110) THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Severe Hypertension (' || COALESCE(v_latest_visit.systolic, 0) || '/' || COALESCE(v_latest_visit.diastolic, 0) || ' mmHg)');
    END IF;

    IF 'vaginal_bleeding' = ANY(v_latest_visit.danger_signs) THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Reported Vaginal Bleeding');
    END IF;

    IF 'severe_headache' = ANY(v_latest_visit.danger_signs) THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Severe Headache / Blurred Vision');
    END IF;

    IF 'convulsions' = ANY(v_latest_visit.danger_signs) THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Convulsions / Fits');
    END IF;

    IF 'reduced_fetal_movement' = ANY(v_latest_visit.danger_signs) OR 'absent_fetal_movement' = ANY(v_latest_visit.danger_signs) THEN
        v_is_immediate_danger := true;
        v_reasons := array_append(v_reasons, 'Reduced or Absent Fetal Movement');
    END IF;

    -- ──────────────────────────────────────────────────────────────────────────
    -- STEP 2: Weighted Points Scoring
    -- ──────────────────────────────────────────────────────────────────────────
    IF v_age < 18 OR v_age > 35 THEN
        v_score := v_score + 2;
        v_reasons := array_append(v_reasons, 'Age Risk Factor (' || v_age || ' yrs)');
    END IF;

    IF (v_latest_visit.systolic >= 140 AND v_latest_visit.systolic < 160) OR 
       (v_latest_visit.diastolic >= 90 AND v_latest_visit.diastolic < 110) THEN
        v_score := v_score + 3;
        v_reasons := array_append(v_reasons, 'Stage 1 High BP (' || v_latest_visit.systolic || '/' || v_latest_visit.diastolic || ' mmHg)');
    END IF;

    IF v_latest_visit.hemoglobin >= 7.0 AND v_latest_visit.hemoglobin < 10.0 THEN
        v_score := v_score + 2;
        v_reasons := array_append(v_reasons, 'Moderate Anemia (Hb ' || v_latest_visit.hemoglobin || ' g/dL)');
    ELSIF v_latest_visit.hemoglobin >= 10.0 AND v_latest_visit.hemoglobin < 11.0 THEN
        v_score := v_score + 1;
        v_reasons := array_append(v_reasons, 'Mild Anemia (Hb ' || v_latest_visit.hemoglobin || ' g/dL)');
    END IF;

    -- Obstetric history (capped at 4 pts)
    IF v_patient.previous_c_section THEN v_obstetric_points := v_obstetric_points + 2; END IF;
    IF v_patient.stillbirth_history THEN v_obstetric_points := v_obstetric_points + 2; END IF;
    IF v_patient.pregnancy_loss_history THEN v_obstetric_points := v_obstetric_points + 2; END IF;
    IF v_patient.pph_history THEN v_obstetric_points := v_obstetric_points + 2; END IF;
    v_score := v_score + LEAST(v_obstetric_points, 4);

    IF v_patient.is_twin THEN
        v_score := v_score + 3;
        v_reasons := array_append(v_reasons, 'Twin Pregnancy');
    END IF;

    IF v_patient.has_diabetes OR v_patient.has_gestational_diabetes THEN
        v_score := v_score + 2;
        v_reasons := array_append(v_reasons, 'Diabetes');
    END IF;

    IF v_patient.rh_negative THEN
        v_score := v_score + 1;
        v_reasons := array_append(v_reasons, 'Rh-Negative Blood Group');
    END IF;

    IF v_missed_days >= 7 THEN
        v_score := v_score + 3;
        v_reasons := array_append(v_reasons, 'Missed Medicines 7+ Days (' || v_missed_days || ' days)');
    ELSIF v_missed_days >= 3 THEN
        v_score := v_score + 2;
        v_reasons := array_append(v_reasons, 'Missed Medicines 3-6 Days (' || v_missed_days || ' days)');
    END IF;

    -- Trends: BP rising >= 20 mmHg
    IF v_latest_visit.systolic IS NOT NULL AND v_prev_visit.systolic IS NOT NULL AND (v_latest_visit.systolic - v_prev_visit.systolic) >= 20 THEN
        v_score := v_score + 2;
        v_reasons := array_append(v_reasons, 'Systolic BP Rising across visits (+ ' || (v_latest_visit.systolic - v_prev_visit.systolic) || ' mmHg)');
    END IF;

    -- Trends: Hb falling >= 1.0 g/dL
    IF v_latest_visit.hemoglobin IS NOT NULL AND v_prev_visit.hemoglobin IS NOT NULL AND (v_prev_visit.hemoglobin - v_latest_visit.hemoglobin) >= 1.0 THEN
        v_score := v_score + 1;
        v_reasons := array_append(v_reasons, 'Hemoglobin Falling (- ' || (v_prev_visit.hemoglobin - v_latest_visit.hemoglobin) || ' g/dL)');
    END IF;

    -- ──────────────────────────────────────────────────────────────────────────
    -- STEP 3: Assign Final Level
    -- ──────────────────────────────────────────────────────────────────────────
    IF v_is_immediate_danger OR v_score >= 5 THEN
        v_level := 'high';
    ELSIF v_score >= 3 THEN
        v_level := 'moderate';
    ELSE
        v_level := 'low';
    END IF;

    -- Save to risk_assessments audit table
    INSERT INTO public.risk_assessments (patient_id, score, level, reasons, trigger)
    VALUES (p_patient_id, v_score, v_level, to_jsonb(v_reasons), 'batch_job');

    RETURN jsonb_build_object(
        'level', v_level,
        'score', v_score,
        'is_immediate_danger', v_is_immediate_danger,
        'reasons', to_jsonb(v_reasons),
        'missed_days', v_missed_days
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 2. AUTOMATED MISSED-DOSE JOB & CLOSED-LOOP ALERT TRIGGER
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_missed_medicines_job()
RETURNS TABLE(alerts_created INT, patients_checked INT) AS $$
DECLARE
    r RECORD;
    v_alerts_count INT := 0;
    v_patients_count INT := 0;
    v_assigned_asha_id UUID;
    v_patient_name TEXT;
    v_risk_result JSONB;
BEGIN
    FOR r IN SELECT id FROM public.patients LOOP
        v_patients_count := v_patients_count + 1;
        
        -- Compute risk
        v_risk_result := public.calculate_patient_risk(r.id);

        -- If missed days >= 3, trigger or update alert
        IF (v_risk_result->>'missed_days')::INT >= 3 THEN
            -- Find assigned ASHA
            SELECT a.asha_id, p.name INTO v_assigned_asha_id, v_patient_name
            FROM public.assignments a
            JOIN public.patients pat ON pat.id = a.patient_id
            JOIN public.profiles p ON p.id = pat.profile_id
            WHERE a.patient_id = r.id AND a.is_active = true
            LIMIT 1;

            -- Create alert if not already open
            IF NOT EXISTS (
                SELECT 1 FROM public.alerts 
                WHERE patient_id = r.id 
                AND type = 'missed_dose_3_days' 
                AND status IN ('open', 'acknowledged')
            ) THEN
                INSERT INTO public.alerts (
                    patient_id,
                    type,
                    severity,
                    status,
                    assigned_to,
                    message
                ) VALUES (
                    r.id,
                    'missed_dose_3_days',
                    'urgent',
                    'open',
                    v_assigned_asha_id,
                    '🚨 Medicine Alert: ' || COALESCE(v_patient_name, 'Mother') || ' has missed medication for ' || (v_risk_result->>'missed_days') || ' consecutive days!'
                );
                v_alerts_count := v_alerts_count + 1;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY SELECT v_alerts_count, v_patients_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 3. ASHA ESCALATION TO ANM
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.escalate_alert_to_anm(
    p_alert_id UUID,
    p_asha_id UUID,
    p_notes TEXT
)
RETURNS UUID AS $$
DECLARE
    v_alert RECORD;
    v_anm_id UUID;
    v_escalation_id UUID;
BEGIN
    SELECT * INTO v_alert FROM public.alerts WHERE id = p_alert_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Alert not found';
    END IF;

    -- Look up the ANM assigned to this patient
    SELECT anm_id INTO v_anm_id FROM public.assignments 
    WHERE patient_id = v_alert.patient_id LIMIT 1;

    -- Update alert status
    UPDATE public.alerts 
    SET status = 'escalated'
    WHERE id = p_alert_id;

    -- Insert escalation record
    INSERT INTO public.escalations (
        alert_id,
        escalated_by,
        escalated_to,
        decision_notes
    ) VALUES (
        p_alert_id,
        p_asha_id,
        v_anm_id,
        p_notes
    ) RETURNING id INTO v_escalation_id;

    RETURN v_escalation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 4. ANM DECISION (CONFIRM HRP, CLEAR, REFER)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.decide_anm_escalation(
    p_alert_id UUID,
    p_anm_id UUID,
    p_decision TEXT, -- 'confirm_hrp', 'clear', 'refer_to_phc'
    p_decision_notes TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_alert RECORD;
BEGIN
    SELECT * INTO v_alert FROM public.alerts WHERE id = p_alert_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Alert not found';
    END IF;

    -- 1. If Confirm HRP: update patient clinical record
    IF p_decision = 'confirm_hrp' THEN
        UPDATE public.patients
        SET is_confirmed_hrp = true,
            hrp_category = 'Confirmed by ANM: ' || p_decision_notes,
            confirmed_by_anm_id = p_anm_id,
            confirmed_at = now()
        WHERE id = v_alert.patient_id;
    END IF;

    -- 2. Update escalation record
    UPDATE public.escalations
    SET decision = p_decision,
        decision_notes = p_decision_notes,
        decided_by = p_anm_id,
        decided_at = now()
    WHERE alert_id = p_alert_id;

    -- 3. Close the alert
    UPDATE public.alerts
    SET status = 'closed',
        closed_at = now(),
        closed_by = p_anm_id,
        resolution_notes = p_decision || ': ' || p_decision_notes
    WHERE id = p_alert_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 5. PG_CRON SCHEDULER (Commented for manual setup in Supabase SQL editor)
-- ----------------------------------------------------------------------------
-- SELECT cron.schedule(
--     'maternal_missed_dose_job',
--     '0 */6 * * *', -- Every 6 hours
--     $$SELECT public.check_missed_medicines_job();$$
-- );
