part of '../../pages/main_edit.dart';

class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color divider   = Color(0xFFE8E8E8);
  static const Color remove    = Color(0xFFE53935);
  static const Color back      = Color(0xFFF1F2ED);
}

const List<Map<String, String>> _kRoutes = [
  {'key': '',            'value': 'None'},
  {'key': '/',           'value': 'Home (/)'},
  {'key': '/services',   'value': 'Overview (/services)'},
  {'key': '/about',      'value': 'Our Products (/about)'},
  {'key': '/contact',    'value': 'About Us (/contact)'},
  {'key': '/terms',      'value': 'Terms of Service (/terms)'},
  {'key': '/contactus',  'value': 'Contact Us (/contactus)'},
];

const List<Map<String, String>> _kLabelDestinations = [
  {'key': '',                                    'value': 'None'},
  {'key': '/',                                   'value': 'Home'},
  {'key': '/services',                           'value': 'Overview'},
  {'key': '/about',                              'value': 'Our Products'},
  {'key': '/contact',                            'value': 'Contact Us'},
  {'key': '/terms',                              'value': 'Terms of Service'},
  {'key': '/about?tab=client-service',           'value': 'Client Service'},
  {'key': '/about?tab=owner-service',            'value': 'Owner Service'},
  {'key': '/about?tab=our-strategy',             'value': 'Our Strategy'},
  {'key': '/about?tab=terms-and-conditions',     'value': 'Terms & Conditions'},
  {'key': '/about?tab=privacy-policy',           'value': 'Privacy Policy'},
  {'key': '/about?tab=vision',                   'value': 'Vision'},
  {'key': '/about?tab=mission',                  'value': 'Mission'},
  {'key': '/about?tab=values',                   'value': 'Values'},
  // ← REMOVED: Why Join Our Team, Our Interns, Our Team
  // ← ADDED:
  {'key': '/request-demo',                       'value': 'Request Demo'},
  {'key': '/contactus?type=client',              'value': 'User Contact'},
  {'key': '/contactus?type=owner',               'value': 'Owner Contact'},
];

const List<Map<String, String>> _kFonts = [
  {'key': 'Cairo',     'value': 'Cairo'},
  {'key': 'Roboto',    'value': 'Roboto'},
  {'key': 'Poppins',   'value': 'Poppins'},
  {'key': 'Tajawal',   'value': 'Tajawal'},
  {'key': 'Almarai',   'value': 'Almarai'},
  {'key': 'Noto Sans', 'value': 'Noto Sans'},
];
