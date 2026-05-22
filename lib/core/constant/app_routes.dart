/// Shared navigation routes, fonts, and dropdown data for beauty_admin.
///
/// Import this instead of redeclaring _kRoutes / _kFonts / _kAllCountries
/// inside every feature's c.dart file.
class AppRoutes {
  AppRoutes._();

  // ── Nav-bar page routes ──────────────────────────────────────────────────
  static const List<Map<String, String>> routes = [
    {'key': '',           'value': 'None'},
    {'key': '/',          'value': 'Home (/)'},
    {'key': '/services',  'value': 'Overview (/services)'},
    {'key': '/about',     'value': 'Our Products (/about)'},
    {'key': '/contact',   'value': 'About Us (/contact)'},
    {'key': '/terms',     'value': 'Terms of Service (/terms)'},
    {'key': '/contactus', 'value': 'Contact Us (/contactus)'},
  ];

  // ── Button / label link destinations ────────────────────────────────────
  static const List<Map<String, String>> labelDestinations = [
    {'key': '',                                'value': 'None'},
    {'key': '/',                               'value': 'Home'},
    {'key': '/services',                       'value': 'Overview'},
    {'key': '/about',                          'value': 'Our Products'},
    {'key': '/contact',                        'value': 'Contact Us'},
    {'key': '/terms',                          'value': 'Terms of Service'},
    {'key': '/about?tab=client-service',       'value': 'Client Service'},
    {'key': '/about?tab=owner-service',        'value': 'Owner Service'},
    {'key': '/about?tab=our-strategy',         'value': 'Our Strategy'},
    {'key': '/about?tab=terms-and-conditions', 'value': 'Terms & Conditions'},
    {'key': '/about?tab=privacy-policy',       'value': 'Privacy Policy'},
    {'key': '/about?tab=vision',               'value': 'Vision'},
    {'key': '/about?tab=mission',              'value': 'Mission'},
    {'key': '/about?tab=values',               'value': 'Values'},
    {'key': '/request-demo',                   'value': 'Request Demo'},
    {'key': '/contactus?type=client',          'value': 'User Contact'},
    {'key': '/contactus?type=owner',           'value': 'Owner Contact'},
  ];

  // ── Font options ──────────────────────────────────────────────────────────
  static const List<Map<String, String>> fonts = [
    {'key': 'Cairo',     'value': 'Cairo'},
    {'key': 'Roboto',    'value': 'Roboto'},
    {'key': 'Poppins',   'value': 'Poppins'},
    {'key': 'Tajawal',   'value': 'Tajawal'},
    {'key': 'Almarai',   'value': 'Almarai'},
    {'key': 'Noto Sans', 'value': 'Noto Sans'},
  ];

  // ── Date helpers ──────────────────────────────────────────────────────────
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<int> allMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  // ── Inquiry / demo dropdown options ───────────────────────────────────────
  static const List<String> allStatuses = ['New', 'Replied', 'Closed'];
  static const List<String> allGenders  = ['Male', 'Female', 'Other'];

  // ── Demo table headers ────────────────────────────────────────────────────
  static const List<String> staticHeadersLeft = [
    'Submission Date',
    'Salon Name',
    'Country',
    'City',
    'No.Branches',
    'No.Employees',
    'First Name',
    'Last Name',
    'Phone Number',
    'Email',
  ];

  static const List<String> staticHeadersRight = [
    'Inquiry Priority',
    'Inquiry Relevance',
    'Required Action',
    'Notes',
    'Status',
  ];

  // ── Demo entity types ─────────────────────────────────────────────────────
  static const List<String> allEntityTypes = [
    'Salon', 'Spa', 'Barbershop', 'Nail Studio', 'Beauty Center',
    'Wellness Center', 'Hair Studio', 'Medical Spa', 'Other',
  ];

  // ── Countries ─────────────────────────────────────────────────────────────
  static const List<String> allCountries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola',
    'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan',
    'Bahrain', 'Bangladesh', 'Belarus', 'Belgium', 'Bolivia',
    'Bosnia and Herzegovina', 'Brazil', 'Bulgaria', 'Cambodia', 'Cameroon',
    'Canada', 'Chile', 'China', 'Colombia', 'Croatia',
    'Cuba', 'Cyprus', 'Czech Republic', 'Denmark', 'Ecuador',
    'Egypt', 'Estonia', 'Ethiopia', 'Finland', 'France',
    'Georgia', 'Germany', 'Ghana', 'Greece', 'Hungary',
    'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland',
    'Israel', 'Italy', 'Japan', 'Jordan', 'Kazakhstan',
    'Kenya', 'Kuwait', 'Latvia', 'Lebanon', 'Libya',
    'Lithuania', 'Luxembourg', 'Malaysia', 'Mexico', 'Morocco',
    'Netherlands', 'New Zealand', 'Nigeria', 'Norway', 'Oman',
    'Pakistan', 'Palestine', 'Panama', 'Peru', 'Philippines',
    'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia',
    'Saudi Arabia', 'Serbia', 'Singapore', 'Slovakia', 'Slovenia',
    'Somalia', 'South Africa', 'South Korea', 'Spain', 'Sri Lanka',
    'Sudan', 'Sweden', 'Switzerland', 'Syria', 'Taiwan',
    'Thailand', 'Tunisia', 'Turkey', 'Ukraine', 'United Arab Emirates',
    'United Kingdom', 'United States', 'Uruguay', 'Venezuela', 'Vietnam',
    'Yemen', 'Zimbabwe',
  ];
}
