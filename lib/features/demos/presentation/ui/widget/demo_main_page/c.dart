part of '../../pages/demo_main_page.dart';

class _C {
  static const Color primary      = Color(0xFFD16F9A);
  static const Color primaryLight = Color(0xFFE8A0BE);
  static const Color back         = Color(0xFFF5F5F5);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color labelText    = Color(0xFF333333);
  static const Color hintText     = Color(0xFFAAAAAA);
  static const Color border       = Color(0xFFE0E0E0);
}

const List<String> _kMonthNames = [
  'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
];

// ─────────────────────────────────────────────────────────────────────────────
//  STATIC HEADERS (always shown — before & after dynamic questions)
// ─────────────────────────────────────────────────────────────────────────────
const List<String> _kStaticHeadersLeft = [
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

const List<String> _kStaticHeadersRight = [
  'Inquiry Priority',
  'Inquiry Relevance',
  'Required Action',
  'Notes',
  'Status',
];

// ─────────────────────────────────────────────────────────────────────────────
//  FIXED DROPDOWN LISTS
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _kAllStatuses = ['New', 'Replied', 'Closed'];

const List<int> _kAllMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const List<String> _kAllCountries = [
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

const List<String> _kAllEntityTypes = [
  'Salon', 'Spa', 'Barbershop', 'Nail Studio', 'Beauty Center',
  'Wellness Center', 'Hair Studio', 'Medical Spa', 'Other',
];

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
