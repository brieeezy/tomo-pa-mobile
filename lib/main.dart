import 'package:flutter/material.dart';

const forest = Color(0xFF5D773D);
const ink = Color(0xFF263126);
const muted = Color(0xFF81877B);
const canvas = Color(0xFFF7F8F5);
const line = Color(0xFFE9EBE4);

void main() => runApp(const TomoApp());

class TomoApp extends StatelessWidget {
  const TomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: forest, primary: forest);
    return MaterialApp(
      title: 'Tomo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: canvas,
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const TomoShell(),
    );
  }
}

class TomoShell extends StatefulWidget {
  const TomoShell({super.key});

  @override
  State<TomoShell> createState() => _TomoShellState();
}

class _TomoShellState extends State<TomoShell> {
  int selected = 0;
  bool unread = true;
  final labels = const ['Home', 'Find work', 'Updates', 'Invoices'];
  final icons = const [
    Icons.home_rounded,
    Icons.work_outline_rounded,
    Icons.notifications_none_rounded,
    Icons.receipt_long_outlined,
  ];

  void openPage(int index) => setState(() => selected = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text('t', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, height: 1)),
          ),
          const SizedBox(width: 8),
          const Text('tomo', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          const Text('.', style: TextStyle(color: forest, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => openPage(2),
            icon: Stack(clipBehavior: Clip.none, children: [
              const Icon(Icons.notifications_none_rounded),
              if (unread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFD37A59), shape: BoxShape.circle)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 18),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8D9CB),
              child: const Text('JL', style: TextStyle(color: Color(0xFF6E5040), fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: selected, children: [
        const HomePage(),
        const JobsPage(),
        NotificationsPage(onMarkRead: () => setState(() => unread = false)),
        const InvoicesPage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: openPage,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF0E3),
        height: 68,
        destinations: [
          for (var i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon(icons[i]),
              selectedIcon: Icon(icons[i], color: forest),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 28), children: [
      const Eyebrow('WEDNESDAY, 29 OCTOBER 2026'),
      const SizedBox(height: 6),
      const Text('Good morning, Jamie ✳', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: ink)),
      const SizedBox(height: 5),
      const Text('Here’s what’s happening with your work today.', style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 20),
      const WelcomeCard(),
      const SizedBox(height: 23),
      const SectionHeader('Your overview', subtitle: 'A quick look at work and earnings.'),
      const SizedBox(height: 12),
      const Row(children: [
        Expanded(child: MetricCard(label: 'APPLICATIONS', value: '04', note: '+2 new this week', icon: Icons.work_outline_rounded, tint: Color(0xFFF0EDF6), iconColor: Color(0xFF8875AA))),
        SizedBox(width: 9),
        Expanded(child: MetricCard(label: 'TO COME', value: '\$2,840', note: '3 open invoices', icon: Icons.south_west_rounded, tint: Color(0xFFEDF3E7), iconColor: forest)),
      ]),
      const SizedBox(height: 9),
      const MetricCard(label: 'PAID THIS MONTH', value: '\$4,260', note: '↑ 12% vs. last month', icon: Icons.check_rounded, tint: Color(0xFFFAF1E8), iconColor: Color(0xFFC08354), wide: true),
      const SizedBox(height: 24),
      const SectionHeader('Recent activity', subtitle: 'Your latest updates.'),
      const SizedBox(height: 10),
      ActivityTile(icon: Icons.auto_awesome_outlined, tint: const Color(0xFFEEF2E7), title: '3 new jobs match your profile', detail: 'New work is waiting in your area.', time: 'Today · 9:42 AM', onTap: () => _go(context, 1)),
      ActivityTile(icon: Icons.check_rounded, tint: const Color(0xFFEAF3E9), title: 'Application confirmed', detail: 'Northstar Studio wants to work with you.', time: 'Today · 8:15 AM', onTap: () => _go(context, 2)),
      ActivityTile(icon: Icons.receipt_long_outlined, tint: const Color(0xFFF6EEE6), title: 'Invoice #INV-024 paid', detail: 'Your $1,200 payment is on its way.', time: 'Yesterday · 2:18 PM', onTap: () => _go(context, 3)),
    ]);
  }
}

void _go(BuildContext context, int index) {
  final shell = context.findAncestorStateOfType<_TomoShellState>();
  shell?.openPage(index);
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: const Color(0xFFDFE8D2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(children: [
          Positioned(right: -23, top: -8, child: Container(width: 126, height: 126, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFB2C39F), width: 1.4)))),
          Positioned(right: 0, top: 16, child: Container(width: 73, height: 73, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFBDCEA9)))),
          Positioned(right: 28, top: 55, child: Container(width: 94, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFCFCF7), borderRadius: BorderRadius.circular(9), boxShadow: const [BoxShadow(color: Color(0x223D5030), blurRadius: 12)]), child: const Text('✳  New work', style: TextStyle(color: forest, fontSize: 10, fontWeight: FontWeight.w600)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('✳  YOUR WEEK AT A GLANCE', style: TextStyle(color: Color(0xFF617446), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            const Text('Good work deserves\ngood momentum.', style: TextStyle(color: Color(0xFF32432C), fontSize: 20, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
            const SizedBox(height: 7),
            const SizedBox(width: 225, child: Text('Your next opportunity could be just around the corner.', style: TextStyle(color: Color(0xFF6B7960), fontSize: 10, height: 1.45))),
            const SizedBox(height: 12),
            TextButton.icon(onPressed: () => _go(context, 1), style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: const Color(0xFF50683A), visualDensity: VisualDensity.compact), icon: const SizedBox.shrink(), label: const Text('Explore job matches   →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ]),
      );
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, required this.note, required this.icon, required this.tint, required this.iconColor, this.wide = false});
  final String label, value, note;
  final IconData icon;
  final Color tint, iconColor;
  final bool wide;

  @override
  Widget build(BuildContext context) => Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: const TextStyle(color: muted, fontSize: 8, letterSpacing: .6, fontWeight: FontWeight.w700))), Container(width: 25, height: 25, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: iconColor))]),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.6)),
          const SizedBox(height: 3),
          Text(note, style: const TextStyle(color: muted, fontSize: 9)),
        ]),
      );
}

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 17, 18, 28), children: [
        const Eyebrow('YOUR NEXT OPPORTUNITY'),
        const SizedBox(height: 6),
        const Text('Find work that fits.', style: TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w700, letterSpacing: -.7)),
        const SizedBox(height: 5),
        const Text('Fresh opportunities picked for your skills.', style: TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 19),
        Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFEEF3E8), border: Border.all(color: const Color(0xFFE5EBDC)), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.auto_awesome, color: forest, size: 20), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('3 new jobs just for you', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Fresh matches for your skills and preferences.', style: TextStyle(fontSize: 9, color: muted))]))])),
        const SizedBox(height: 15),
        const JobCard(letter: 'N', company: 'Northstar Studio', title: 'Brand identity designer', category: 'DESIGN · REMOTE', pay: '\$1,200', tags: 'Branding  ·  Figma  ·  Contract', fresh: true),
        const JobCard(letter: 'M', company: 'Morrow & Co.', title: 'Social media content creator', category: 'CONTENT · HYBRID', pay: '\$45 / hour', tags: 'Social media  ·  Copywriting', fresh: true),
        const JobCard(letter: 'P', company: 'Pebble Goods', title: 'Product photographer', category: 'PHOTOGRAPHY · ONSITE', pay: '\$680', tags: 'Product  ·  Photography', fresh: false),
      ]);
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.letter, required this.company, required this.title, required this.category, required this.pay, required this.tags, required this.fresh});
  final String letter, company, title, category, pay, tags;
  final bool fresh;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFEBF0E4), borderRadius: BorderRadius.circular(10)), child: Text(letter, style: const TextStyle(color: forest, fontWeight: FontWeight.w700, fontSize: 16))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category, style: const TextStyle(color: muted, fontSize: 7, letterSpacing: .7, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)), const SizedBox(height: 3), Text('$company  ·  Singapore', style: const TextStyle(color: muted, fontSize: 9))])),
            if (fresh) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEDF3E8), borderRadius: BorderRadius.circular(5)), child: const Text('NEW', style: TextStyle(color: forest, fontSize: 7, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 11),
          Text(tags, style: const TextStyle(color: muted, fontSize: 8)),
          const SizedBox(height: 12),
          Row(children: [Text(pay, style: const TextStyle(fontSize: 12, color: forest, fontWeight: FontWeight.w700)), const Spacer(), OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application started for $title'))), style: OutlinedButton.styleFrom(foregroundColor: forest, side: const BorderSide(color: Color(0xFFE2E7DC)), padding: const EdgeInsets.symmetric(horizontal: 12), visualDensity: VisualDensity.compact), child: const Text('View job  →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)))]),
        ]),
      );
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.onMarkRead});
  final VoidCallback? onMarkRead;
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String filter = 'All';
  bool unread = true;
  @override
  Widget build(BuildContext context) {
    final items = [
      const Notice(icon: Icons.auto_awesome_outlined, title: '3 new jobs match your profile', time: '9:42 AM', body: 'Fresh opportunities in design and content creation are waiting for you.', type: 'Jobs', link: 'Explore new jobs'),
      const Notice(icon: Icons.check_rounded, title: 'You got the job, Jamie!', time: '8:15 AM', body: 'Northstar Studio accepted your application for Brand identity designer. Your project is confirmed.', type: 'Jobs', link: 'View project details', confirmation: true),
      const Notice(icon: Icons.receipt_long_outlined, title: 'Invoice #INV-024 has been paid', time: 'Yesterday', body: '\$1,200.00 from Northstar Studio is on its way to your account.', type: 'Invoices', link: 'View invoice'),
      const Notice(icon: Icons.visibility_outlined, title: 'Your application was viewed', time: 'Yesterday', body: 'Morrow & Co. viewed your application for Social media content creator.', type: 'Jobs'),
      const Notice(icon: Icons.schedule_rounded, title: 'Invoice #INV-026 is due soon', time: 'Monday', body: 'Your \$540.00 invoice for Pebble Goods is due in 3 days.', type: 'Invoices', link: 'Review invoice'),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(18, 17, 18, 28), children: [
      const Eyebrow('A LITTLE GOOD NEWS'),
      const SizedBox(height: 6),
      Row(children: [const Expanded(child: Text('Notifications', style: TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w700, letterSpacing: -.7))), TextButton(onPressed: () { setState(() => unread = false); widget.onMarkRead?.call(); }, child: const Text('Mark all read', style: TextStyle(fontSize: 10, color: forest)))]),
      const SizedBox(height: 4),
      const Text('Stay in the loop. Your work is moving forward.', style: TextStyle(color: muted, fontSize: 11)),
      const SizedBox(height: 18),
      Wrap(spacing: 7, children: ['All', 'Jobs', 'Invoices'].map((item) => ChoiceChip(label: Text(item), selected: filter == item, onSelected: (_) => setState(() => filter = item), labelStyle: TextStyle(fontSize: 10, color: filter == item ? forest : muted), selectedColor: const Color(0xFFEDF2E7), backgroundColor: Colors.white, side: BorderSide(color: filter == item ? const Color(0xFFE3EADB) : line))).toList()),
      const SizedBox(height: 12),
      const Eyebrow('TODAY'),
      for (var i = 0; i < items.length; i++)
        if (filter == 'All' || items[i].type == filter)
          NoticeCard(notice: items[i], unread: unread && i < 2, onTap: () {
            if (items[i].confirmation) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project confirmed · Starts Nov 2 · Agreed fee \$1,200')));
            else if (items[i].link != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(items[i].link!)));
          }),
    ]);
  }
}

class Notice {
  const Notice({required this.icon, required this.title, required this.time, required this.body, required this.type, this.link, this.confirmation = false});
  final IconData icon;
  final String title, time, body, type;
  final String? link;
  final bool confirmation;
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice, required this.unread, required this.onTap});
  final Notice notice;
  final bool unread;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(color: unread ? const Color(0xFFFBFCF9) : Colors.white, border: Border.all(color: unread ? const Color(0xFFE1E8D9) : line), borderRadius: BorderRadius.circular(12)),
        child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: notice.confirmation ? const Color(0xFFE9F2E7) : const Color(0xFFEEF2E7), borderRadius: BorderRadius.circular(9)), child: Icon(notice.icon, color: notice.confirmation ? const Color(0xFF5F8B57) : forest, size: 17)),
          const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(notice.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink))), Text(notice.time, style: const TextStyle(color: muted, fontSize: 8))]), const SizedBox(height: 6), Text(notice.body, style: const TextStyle(color: muted, fontSize: 9, height: 1.5)), if (notice.confirmation) Container(width: double.infinity, margin: const EdgeInsets.only(top: 9), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFFF7F8F4), borderRadius: BorderRadius.circular(8)), child: const Text('PROJECT STARTS  ·  Mon, Nov 2\nAGREED FEE  ·  \$1,200.00', style: TextStyle(color: Color(0xFF59634F), fontSize: 8, height: 1.8, fontWeight: FontWeight.w600))), if (notice.link != null) Padding(padding: const EdgeInsets.only(top: 7), child: Text('${notice.link}  →', style: const TextStyle(color: forest, fontSize: 9, fontWeight: FontWeight.w700)))])),
        ]))),
      );
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 17, 18, 28), children: [
        const Eyebrow('MONEY IN, MADE SIMPLE'),
        const SizedBox(height: 6),
        const Text('Invoices & earnings', style: TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w700, letterSpacing: -.7)),
        const SizedBox(height: 5),
        const Text('See what’s coming in and how your work is paying off.', style: TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: line), borderRadius: BorderRadius.circular(13)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Eyebrow('TOTAL EARNED THIS MONTH'), const SizedBox(height: 7), const Text('\$4,260.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.8, color: ink)), const SizedBox(height: 3), const Text('↗ 12% compared to September', style: TextStyle(color: forest, fontSize: 9, fontWeight: FontWeight.w600)), const SizedBox(height: 15), SizedBox(height: 95, child: CustomPaint(painter: EarningsPainter(), child: const SizedBox.expand())), const SizedBox(height: 8), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('OCT 1', style: TinyLabel()), Text('OCT 7', style: TinyLabel()), Text('OCT 14', style: TinyLabel()), Text('OCT 21', style: TinyLabel()), Text('OCT 29', style: TinyLabel())])])),
        const SizedBox(height: 10),
        const Row(children: [Expanded(child: BalanceCard(label: 'PAID', amount: '\$4,260', status: '4 invoices', icon: Icons.check_circle_outline_rounded, color: forest)), SizedBox(width: 8), Expanded(child: BalanceCard(label: 'PENDING', amount: '\$1,650', status: '2 invoices', icon: Icons.schedule_rounded, color: Color(0xFFBE8A47)))]),
        const SizedBox(height: 22),
        Row(children: [const Expanded(child: SectionHeader('Recent invoices', subtitle: 'Every payment, all accounted for.')), TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New invoice draft created'))), icon: const Icon(Icons.add, size: 14), label: const Text('New', style: TextStyle(fontSize: 10)), style: TextButton.styleFrom(foregroundColor: forest))]),
        const SizedBox(height: 8),
        const InvoiceTile(id: 'INV-026', name: 'Product photography', client: 'Pebble Goods', amount: '\$540.00', status: 'Draft', tint: Color(0xFFF8F0E4)),
        const InvoiceTile(id: 'INV-025', name: 'Content strategy', client: 'Morrow & Co.', amount: '\$1,650.00', status: 'Pending', tint: Color(0xFFF0EDF5)),
        const InvoiceTile(id: 'INV-024', name: 'Brand identity design', client: 'Northstar Studio', amount: '\$1,200.00', status: 'Paid', tint: Color(0xFFEBF0E4)),
        const InvoiceTile(id: 'INV-023', name: 'Social content package', client: 'Fern & Form', amount: '\$1,400.00', status: 'Paid', tint: Color(0xFFF7ECE4)),
        Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFEEF3E8), borderRadius: BorderRadius.circular(11)), child: const Row(children: [Icon(Icons.auto_awesome_outlined, size: 18, color: forest), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your earnings are growing', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('You earned 12% more this month. Brand identity projects are your top category.', style: TextStyle(fontSize: 9, color: muted, height: 1.45))]))])),
      ]);
}

class EarningsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFEFF0EB)..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final points = [Offset(0, size.height * .82), Offset(size.width * .15, size.height * .65), Offset(size.width * .31, size.height * .69), Offset(size.width * .48, size.height * .43), Offset(size.width * .63, size.height * .53), Offset(size.width * .79, size.height * .29), Offset(size.width, size.height * .08)];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final next = points[i];
      final mid = (previous.dx + next.dx) / 2;
      path.cubicTo(mid, previous.dy, mid, next.dy, next.dx, next.dy);
    }
    final area = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(area, Paint()..shader = const LinearGradient(colors: [Color(0x447F9C5D), Color(0x007F9C5D)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size));
    canvas.drawPath(path, Paint()..color = forest..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.label, required this.amount, required this.status, required this.icon, required this.color});
  final String label, amount, status;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: line), borderRadius: BorderRadius.circular(11)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 17, color: color), const SizedBox(height: 9), Text(label, style: const TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: .6)), const SizedBox(height: 4), Text(amount, style: const TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(status, style: const TextStyle(color: muted, fontSize: 8))]));
}

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.id, required this.name, required this.client, required this.amount, required this.status, required this.tint});
  final String id, name, client, amount, status;
  final Color tint;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: line), borderRadius: BorderRadius.circular(11)), child: Row(children: [Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.receipt_long_outlined, size: 16, color: forest)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('#$id · $name', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: ink)), const SizedBox(height: 4), Text(client, style: const TextStyle(fontSize: 8, color: muted))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(amount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ink)), const SizedBox(height: 4), Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: status == 'Paid' ? forest : const Color(0xFFA57E44)))]) ]));
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.icon, required this.tint, required this.title, required this.detail, required this.time, required this.onTap});
  final IconData icon;
  final Color tint;
  final String title, detail, time;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: line))), child: Row(children: [Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: forest, size: 15)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(detail, style: const TextStyle(fontSize: 9, color: muted)), const SizedBox(height: 3), Text(time, style: const TextStyle(fontSize: 8, color: Color(0xFFA3A79E)))])), const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: muted)])));
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)), if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle!, style: const TextStyle(fontSize: 9, color: muted))]]);
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1));
}

class TinyLabel extends StatelessWidget {
  const TinyLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: muted, fontSize: 7, letterSpacing: .3));
}

