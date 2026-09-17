class MonthDietPlan {
  final int monthIndex;
  final int trimesterIndex;
  final List<String> primaryNutritionalFocus;
  final List<String> primaryNutritionalFocusHi;
  final List<String> primaryNutritionalFocusMr;
  final Map<String, String> mealSchedule;
  final Map<String, String> mealScheduleHi;
  final Map<String, String> mealScheduleMr;

  const MonthDietPlan({
    required this.monthIndex,
    required this.trimesterIndex,
    required this.primaryNutritionalFocus,
    required this.primaryNutritionalFocusHi,
    required this.primaryNutritionalFocusMr,
    required this.mealSchedule,
    required this.mealScheduleHi,
    required this.mealScheduleMr,
  });
}

const List<MonthDietPlan> maternalDietPlans = [
  MonthDietPlan(
    monthIndex: 1,
    trimesterIndex: 1,
    primaryNutritionalFocus: ["Folate (Vitamin B9)", "Nutrient Density"],
    primaryNutritionalFocusHi: ["फोलेट (विटामिन B9)", "पोषक तत्व घनत्व"],
    primaryNutritionalFocusMr: ["फोलेट (व्हिटॅमिन B9)", "पोषक घनता"],
    mealSchedule: {
      "Early Morning": "Warm water with lemon and a small piece of Jaggery.",
      "Breakfast": "Poha with peanuts and green peas, or Jowar Bhakri with milk.",
      "Mid-Morning": "Fresh local fruit like Guava (Peru) or Banana.",
      "Lunch": "2 Jowar/Bajra Bhakris, 1 bowl Yellow Moong Dal, Palak (Spinach) sabzi.",
      "Evening Snack": "Roasted Chana (Phutane) or Shengdana Chikki (Peanut Jaggery).",
      "Dinner": "Light Dal Khichdi with a teaspoon of Ghee.",
      "Bedtime": "Warm milk with a pinch of Turmeric."
    },
    mealScheduleHi: {
      "Early Morning": "नींबू के साथ गर्म पानी और गुड़ का एक छोटा टुकड़ा।",
      "Breakfast": "मूंगफली और मटर के साथ पोहा, या दूध के साथ ज्वार की भाकरी।",
      "Mid-Morning": "ताजा स्थानीय फल जैसे अमरूद या केला।",
      "Lunch": "2 ज्वार/बाजरे की भाकरी, 1 कटोरी पीली मूंग दाल, पालक की सब्जी।",
      "Evening Snack": "भुना हुआ चना (फुटाने) या मूंगफली की चिक्की।",
      "Dinner": "एक चम्मच घी के साथ हल्का दाल खिचड़ी।",
      "Bedtime": "एक चुटकी हल्दी के साथ गर्म दूध।"
    },
    mealScheduleMr: {
      "Early Morning": "लिंबासोबत कोमट पाणी आणि गुळाचा एक छोटा तुकडा.",
      "Breakfast": "शेंगदाणे आणि वाटाणा घालून पोहे, किंवा दुधासोबत ज्वारीची भाकरी.",
      "Mid-Morning": "पेरू किंवा केळी सारखे ताजे स्थानिक फळ.",
      "Lunch": "२ ज्वारी/बाजरीची भाकरी, १ वाटी पिवळी मूंग डाळ, पालकाची भाजी.",
      "Evening Snack": "भाजलेले फुटाणे किंवा शेंगदाणा चिक्की.",
      "Dinner": "एक चमचा तूप घालून हलकी डाळ खिचडी.",
      "Bedtime": "एक चिमूटभर हळद घालून कोमट दूध."
    },
  ),
  MonthDietPlan(
    monthIndex: 2,
    trimesterIndex: 1,
    primaryNutritionalFocus: ["Organogenesis", "Calcium", "Probiotics"],
    primaryNutritionalFocusHi: ["अंग निर्माण", "कैल्शियम", "प्रोबायोटिक्स"],
    primaryNutritionalFocusMr: ["अवयव निर्मिती", "कॅल्शियम", "प्रोबायोटिक्स"],
    mealSchedule: {
      "Early Morning": "Warm water with a slice of fresh ginger (for nausea).",
      "Breakfast": "Ragi (Nachni) satva cooked in milk, or Moong Dal Chilla.",
      "Mid-Morning": "A glass of fresh Buttermilk (Taak) with roasted cumin.",
      "Lunch": "Rice, mixed vegetable curry, 1 bowl of Tur Dal, fresh cucumber.",
      "Evening Snack": "A handful of dry dates (Khareek) or groundnuts.",
      "Dinner": "2 Rotis with Methi (Fenugreek) sabzi and a side of green beans.",
      "Bedtime": "Warm milk."
    },
    mealScheduleHi: {
      "Early Morning": "मतली (उल्टी) रोकने के लिए ताजे अदरक के टुकड़े के साथ गर्म पानी।",
      "Breakfast": "दूध में पका हुआ रागी (नाचनी) दलिया, या मूंग दाल चिला।",
      "Mid-Morning": "भुना हुआ जीरा के साथ ताज़ा छाछ।",
      "Lunch": "चावल, मिक्स वेजीटेबल करी, 1 कटोरी अरहर (तूर) दाल, ताज़ा ककड़ी।",
      "Evening Snack": "सूखे खजूर (खारीक) या मूंगफली।",
      "Dinner": "मेथी की सब्जी और बीन्स के साथ 2 रोटियां।",
      "Bedtime": "गर्म दूध।"
    },
    mealScheduleMr: {
      "Early Morning": "मळमळ टाळण्यासाठी ताजा आल्याच्या तुकड्यासोबत कोमट पाणी.",
      "Breakfast": "दुधात शिजवलेले नाचणीचे सत्व, किंवा मूग डाळीचे धिरडे.",
      "Mid-Morning": "भाजलेल्या जिरे पूड घालून ताजी ताक.",
      "Lunch": "भात, मिक्स व्हेज करी, १ वाटी तूर डाळ, ताजी काकडी.",
      "Evening Snack": "थोडी खारीक किंवा शेंगदाणे.",
      "Dinner": "मेथीची भाजी आणि हिरव्या फरसबी सोबत २ चपात्या.",
      "Bedtime": "कोमट दूध."
    },
  ),
  MonthDietPlan(
    monthIndex: 3,
    trimesterIndex: 1,
    primaryNutritionalFocus: ["Iron", "Vitamin C"],
    primaryNutritionalFocusHi: ["आयरन", "विटामिन सी"],
    primaryNutritionalFocusMr: ["लोह", "व्हिटॅमिन सी"],
    mealSchedule: {
      "Early Morning": "1 Amla murabba or fresh amla juice.",
      "Breakfast": "Upma with local vegetables, coconut chutney.",
      "Mid-Morning": "Fresh pomegranate (Anar) or Sweet Lime (Mosambi).",
      "Lunch": "2 Rotis, 1 bowl of Sprouted Matki (Moth beans) usal, beetroot salad.",
      "Evening Snack": "Sprouted Moong (Green gram) chaat with a squeeze of lemon.",
      "Dinner": "Rice with mixed lentil soup (Amti).",
      "Bedtime": "Warm milk with a small piece of Jaggery."
    },
    mealScheduleHi: {
      "Early Morning": "1 आंवला मुरब्बा या ताजा आंवला जूस।",
      "Breakfast": "स्थानीय सब्जियों के साथ उपमा, नारियल की चटनी।",
      "Mid-Morning": "ताजा अनार या मौसमी।",
      "Lunch": "2 रोटियां, 1 कटोरी अंकुरित मटकी (मोठ), चुकंदर का सलाद।",
      "Evening Snack": "नींबू के रस के साथ अंकुरित मूंग चाट।",
      "Dinner": "मिश्रित दाल (आमटी) के साथ चावल।",
      "Bedtime": "गुड़ के एक छोटे टुकड़े के साथ गर्म दूध।"
    },
    mealScheduleMr: {
      "Early Morning": "१ आवळा मुरंबा किंवा ताजे आवळ्याचा रस.",
      "Breakfast": "भाज्या घालून उपमा, ओल्या नारळाची चटणी.",
      "Mid-Morning": "ताजे डाळिंब किंवा मोसंबी.",
      "Lunch": "२ चपात्या, १ वाटी मोड आलेली मटकीची उसळ, बीटची कोशिंबीर.",
      "Evening Snack": "लिंबू पिळून मोड आलेली मूग चाट.",
      "Dinner": "आमटी (डाळ) सोबत भात.",
      "Bedtime": "गुळाच्या लहान तुकड्यासोबत कोमट दूध."
    },
  ),
  MonthDietPlan(
    monthIndex: 4,
    trimesterIndex: 2,
    primaryNutritionalFocus: ["Healthy Fats", "Iron"],
    primaryNutritionalFocusHi: ["स्वस्थ वसा", "आयरन"],
    primaryNutritionalFocusMr: ["आरोग्यदायी चरबी", "लोह"],
    mealSchedule: {
      "Early Morning": "Soaked peanuts and a piece of Jaggery.",
      "Breakfast": "Thalipeeth (Multigrain flatbread) with Curd.",
      "Mid-Morning": "Fresh Coconut Water or Nimbu Pani.",
      "Lunch": "Rice, 1 bowl of thick Dal, Bottle Gourd (Lauki/Dudhi) sabzi.",
      "Evening Snack": "Roasted Makhana or puffed rice (Kurmure) Bhel.",
      "Dinner": "2 Rotis with leafy green vegetables.",
      "Bedtime": "Milk boiled with a pinch of cardamom."
    },
    mealScheduleHi: {
      "Early Morning": "भीगी हुई मूंगफली और गुड़ का टुकड़ा।",
      "Breakfast": "दही के साथ थालीपीठ (मल्टीग्रेन रोटी)।",
      "Mid-Morning": "ताजा नारियल पानी या नींबू पानी।",
      "Lunch": "चावल, 1 कटोरी गाढ़ी दाल, लौकी (दूधी) की सब्जी।",
      "Evening Snack": "भुना हुआ मखाना या कुरमुरे की भेल।",
      "Dinner": "हरी पत्तेदार सब्जियों के साथ 2 रोटियां।",
      "Bedtime": "चुटकी भर इलायची के साथ उबला हुआ दूध।"
    },
    mealScheduleMr: {
      "Early Morning": "भिजवलेले शेंगदाणे आणि गुळाचा खडा.",
      "Breakfast": "दह्यासोबत भाजणीचे थालीपीठ.",
      "Mid-Morning": "ताजे शहाळ्याचे पाणी किंवा लिंबू पाणी.",
      "Lunch": "भात, १ वाटी घट्ट वरण, दुधी भोपळ्याची भाजी.",
      "Evening Snack": "भाजलेले मखाणे किंवा कुरमुऱ्याची भेल.",
      "Dinner": "पालेभाजी सोबत २ चपात्या.",
      "Bedtime": "वेलची पूड घालून उकळलेले दूध."
    },
  ),
  MonthDietPlan(
    monthIndex: 5,
    trimesterIndex: 2,
    primaryNutritionalFocus: ["High-Quality Protein"],
    primaryNutritionalFocusHi: ["उच्च गुणवत्ता प्रोटीन"],
    primaryNutritionalFocusMr: ["उच्च प्रतीचे प्रथिने"],
    mealSchedule: { "Early Morning": "Dry fruits", "Breakfast": "Dalia (Broken wheat) Upma", "Mid-Morning": "Sweet Lime (Mosambi)", "Lunch": "Chana (Chickpea) Curry with Roti", "Evening Snack": "Boiled Egg (if non-veg) or Roasted Chana", "Dinner": "Rice & Dal", "Bedtime": "Warm Milk" },
    mealScheduleHi: { "Early Morning": "सूखे मेवे", "Breakfast": "दलिया उपमा", "Mid-Morning": "मौसमी", "Lunch": "चना करी और रोटी", "Evening Snack": "उबला अंडा (यदि मांसाहारी) या भुना चना", "Dinner": "चावल और दाल", "Bedtime": "गर्म दूध" },
    mealScheduleMr: { "Early Morning": "सुका मेवा", "Breakfast": "दलिया उपमा", "Mid-Morning": "मोसंबी", "Lunch": "छोले (हरभरा) करी आणि चपाती", "Evening Snack": "उकडलेले अंडे (मांसाहारी असल्यास) किंवा भाजलेले फुटाणे", "Dinner": "वरण-भात", "Bedtime": "कोमट दूध" },
  ),
  MonthDietPlan(
    monthIndex: 6,
    trimesterIndex: 2,
    primaryNutritionalFocus: ["Fiber", "Hydration"],
    primaryNutritionalFocusHi: ["फाइबर", "जलयोजन"],
    primaryNutritionalFocusMr: ["फायबर", "हायड्रेशन"],
    mealSchedule: { "Early Morning": "Soaked raisins", "Breakfast": "Shevaya (Vermicelli) Upma", "Mid-Morning": "Buttermilk (Taak)", "Lunch": "Pumpkin (Bhopla) sabzi with Bhakri", "Evening Snack": "Fruits", "Dinner": "Vegetable Pulao", "Bedtime": "Turmeric Milk" },
    mealScheduleHi: { "Early Morning": "भीगी किशमिश", "Breakfast": "सेवई उपमा", "Mid-Morning": "छाछ", "Lunch": "कद्दू (भोपला) की सब्जी और भाकरी", "Evening Snack": "फल", "Dinner": "वेजीटेबल पुलाव", "Bedtime": "हल्दी दूध" },
    mealScheduleMr: { "Early Morning": "भिजवलेले मनुके", "Breakfast": "शेवयांचा उपमा", "Mid-Morning": "ताक", "Lunch": "भोपळ्याची भाजी आणि भाकरी", "Evening Snack": "फळे", "Dinner": "व्हेज पुलाव", "Bedtime": "हळदीचे दूध" },
  ),
  MonthDietPlan(
    monthIndex: 7,
    trimesterIndex: 3,
    primaryNutritionalFocus: ["Protein", "Calcium"],
    primaryNutritionalFocusHi: ["प्रोटीन", "कैल्शियम"],
    primaryNutritionalFocusMr: ["प्रथिने", "कॅल्शियम"],
    mealSchedule: { "Early Morning": "Jaggery and Peanuts", "Breakfast": "Besan Chilla", "Mid-Morning": "Guava (Peru)", "Lunch": "Black Chana Usal with Roti", "Evening Snack": "Rajgira (Amaranth) Ladoo", "Dinner": "Khichdi", "Bedtime": "Warm milk" },
    mealScheduleHi: { "Early Morning": "गुड़ और मूंगफली", "Breakfast": "बेसन का चीला", "Mid-Morning": "अमरूद", "Lunch": "काला चना उसल और रोटी", "Evening Snack": "राजगिरा (रामदाना) के लड्डू", "Dinner": "खिचड़ी", "Bedtime": "गर्म दूध" },
    mealScheduleMr: { "Early Morning": "गुळ आणि शेंगदाणे", "Breakfast": "बेसनाचे धिरडे", "Mid-Morning": "पेरू", "Lunch": "काळ्या चण्याची उसळ आणि चपाती", "Evening Snack": "राजगिरा लाडू", "Dinner": "खिचड़ी", "Bedtime": "कोमट दूध" },
  ),
  MonthDietPlan(
    monthIndex: 8,
    trimesterIndex: 3,
    primaryNutritionalFocus: ["Low-Sodium", "Comfort"],
    primaryNutritionalFocusHi: ["कम सोडियम", "आराम"],
    primaryNutritionalFocusMr: ["कमी सोडियम", "आराम"],
    mealSchedule: { "Early Morning": "Coconut water", "Breakfast": "Idli with chutney", "Mid-Morning": "Veg soup", "Lunch": "Rice & Dal", "Evening Snack": "Banana", "Dinner": "Gourd (Dudhi) sabzi", "Bedtime": "Milk" },
    mealScheduleHi: { "Early Morning": "नारियल पानी", "Breakfast": "चटनी के साथ इडली", "Mid-Morning": "वेज सूप", "Lunch": "चावल और दाल", "Evening Snack": "केला", "Dinner": "लौकी की सब्जी", "Bedtime": "दूध" },
    mealScheduleMr: { "Early Morning": "शहाळ्याचे पाणी", "Breakfast": "चटणी सोबत इडली", "Mid-Morning": "व्हेज सूप", "Lunch": "वरण-भात", "Evening Snack": "केळी", "Dinner": "दुधी भोपळ्याची भाजी", "Bedtime": "दूध" },
  ),
  MonthDietPlan(
    monthIndex: 9,
    trimesterIndex: 3,
    primaryNutritionalFocus: ["Labor Preparation"],
    primaryNutritionalFocusHi: ["प्रसव की तैयारी"],
    primaryNutritionalFocusMr: ["बाळंतपणाची तयारी"],
    mealSchedule: { "Early Morning": "Khareek (Dry Dates)", "Breakfast": "Sanjya (Sweet wheat semolina)", "Mid-Morning": "Buttermilk", "Lunch": "Rice, Dal, and Ghee", "Evening Snack": "Dink (Edible Gum) Ladoo", "Dinner": "Light Phulka and Dal", "Bedtime": "Ghee milk" },
    mealScheduleHi: { "Early Morning": "सूखे खजूर (खारीक)", "Breakfast": "संजा (मीठा गेहूं का हलवा)", "Mid-Morning": "छाछ", "Lunch": "चावल, दाल और घी", "Evening Snack": "गोंद के लड्डू (डिंक)", "Dinner": "हल्की रोटी और दाल", "Bedtime": "घी वाला दूध" },
    mealScheduleMr: { "Early Morning": "खारीक", "Breakfast": "सांज्या (गोड शिरा)", "Mid-Morning": "ताक", "Lunch": "भात, वरण आणि तूप", "Evening Snack": "डिंकाचे लाडू", "Dinner": "हलकी पोळी आणि वरण", "Bedtime": "तूप घातलेले दूध" },
  ),
];
