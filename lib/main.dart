import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tomo_api.dart';

const brand = Color(0xFFFF8811);
const ink = Color(0xFF392F5A);
const muted = Color(0xFF746F80);
const paper = Color(0xFFFFF8F0);
const aqua = Color(0xFF9DD9D2);
const aquaSoft = Color(0xFFE8F7F5);

// Temporary development credentials, matching the Tomo web app defaults.
const tomoUsername =
    String.fromEnvironment('TOMO_USERNAME', defaultValue: 'superadmin');
const tomoPassword =
    String.fromEnvironment('TOMO_PASSWORD', defaultValue: 'password');

void main() => runApp(const TomoApp());

class TomoApp extends StatelessWidget {
  const TomoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Tomo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: brand,
            primary: brand,
            secondary: aqua,
            surface: Colors.white,
            error: const Color(0xFFB43F34),
          ),
          scaffoldBackgroundColor: paper,
          fontFamily: 'DM Sans',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Manrope'),
            displayMedium: TextStyle(fontFamily: 'Manrope'),
            displaySmall: TextStyle(fontFamily: 'Manrope'),
            headlineLarge: TextStyle(fontFamily: 'Manrope', color: ink),
            headlineMedium: TextStyle(fontFamily: 'Manrope', color: ink),
            headlineSmall: TextStyle(fontFamily: 'Manrope', color: ink),
            titleLarge: TextStyle(fontFamily: 'Manrope', color: ink),
            titleMedium: TextStyle(color: ink),
            titleSmall: TextStyle(color: ink),
            bodyLarge: TextStyle(color: ink),
            bodyMedium: TextStyle(color: ink),
            bodySmall: TextStyle(color: muted),
            labelLarge: TextStyle(fontWeight: FontWeight.w700),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: paper,
            foregroundColor: ink,
            surfaceTintColor: Colors.transparent,
          ),
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: aquaSoft,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE9E2D9)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: muted),
            hintStyle: const TextStyle(color: muted),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brand, width: 1.5),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: TomoHome(
            api: TomoApi(
                baseUrl: defaultTomoApiUrl,
                username: tomoUsername,
                password: tomoPassword)),
      );
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final url = TextEditingController(text: defaultTomoApiUrl);
  final username = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> connect() async {
    setState(() {
      busy = true;
      error = null;
    });
    final api = TomoApi(
        baseUrl: url.text,
        username: username.text.trim(),
        password: password.text);
    try {
      await api.getJobs();
      if (!mounted) {
        api.close();
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => TomoHome(api: api)), (_) => false);
    } on TomoApiException catch (e) {
      api.close();
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    url.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BrandMark(),
                            const SizedBox(height: 30),
                            const Text('Connect to Tomo',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: ink)),
                            const SizedBox(height: 8),
                            const Text(
                                'Sign in with your Tomo account to get new job alerts, apply to jobs, and chat with your assistant.',
                                style: TextStyle(color: muted, height: 1.5)),
                            const SizedBox(height: 26),
                            TextField(
                                controller: url,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                    labelText: 'Backend URL',
                                    hintText: 'https://your-tomo-server.com',
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(
                                controller: username,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                    labelText: 'Username',
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(
                                controller: password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder()),
                                onSubmitted: (_) => connect()),
                            if (error != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(error!,
                                      style:
                                          const TextStyle(color: Colors.red))),
                            const SizedBox(height: 20),
                            SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                    onPressed: busy ? null : connect,
                                    child: busy
                                        ? const SizedBox.square(
                                            dimension: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : const Text('Connect to Tomo'))),
                            const SizedBox(height: 8),
                            SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                    onPressed: busy
                                        ? null
                                        : () => Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                                builder: (_) =>
                                                    const GuestHome())),
                                    child: const Text('Continue as guest'))),
                            const SizedBox(height: 14),
                            const Text(
                                'For an Android emulator, use http://10.0.2.2:8080. For a phone, enter the Tomo server address reachable on your network.',
                                style: TextStyle(
                                    fontSize: 12, color: muted, height: 1.5)),
                          ]))))));
}

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});
  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      _GuestFeature(
          icon: Icons.notifications_outlined,
          title: 'Your alerts will appear here',
          message:
              'Connect to Tomo to see notifications when a fresh job list is found.'),
      _GuestFeature(
          icon: Icons.work_outline,
          title: 'Explore Tomo jobs',
          message:
              'Connect to your account to browse current jobs, read details, and apply.'),
      _GuestFeature(
          icon: Icons.auto_awesome_outlined,
          title: 'Meet your AI assistant',
          message:
              'Connect to Tomo to ask the assistant about jobs and applications.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const BrandMark()),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: aquaSoft,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Guest preview · Live Tomo data is off',
                        style: TextStyle(
                            color: const Color(0xFF397C74),
                            fontWeight: FontWeight.w600))),
                Expanded(child: pages[tab]),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const ConnectPage()),
                                (_) => false),
                        icon: const Icon(Icons.login),
                        label: const Text('Connect to your Tomo account')))
              ]))),
      bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) => setState(() => tab = index),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
            NavigationDestination(
                icon: Icon(Icons.work_outline), label: 'Jobs'),
            NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined), label: 'Assistant')
          ]),
    );
  }
}

class _GuestFeature extends StatelessWidget {
  const _GuestFeature(
      {required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: brand, size: 44),
        const SizedBox(height: 14),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: ink, fontWeight: FontWeight.w700, fontSize: 19)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.5))
      ]));
}

class TomoHome extends StatefulWidget {
  const TomoHome({super.key, required this.api});
  final TomoApi api;
  @override
  State<TomoHome> createState() => _TomoHomeState();
}

class _TomoHomeState extends State<TomoHome> {
  int tab = 0;
  int unread = 0;
  Timer? poll;
  @override
  void initState() {
    super.initState();
    refreshUnread();
    poll = Timer.periodic(const Duration(seconds: 30), (_) => refreshUnread());
  }

  Future<void> refreshUnread() async {
    try {
      final list = await widget.api.getNotifications();
      if (mounted) setState(() => unread = list.where((n) => !n.isRead).length);
    } catch (_) {}
  }

  @override
  void dispose() {
    poll?.cancel();
    widget.api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const BrandMark(), actions: [
          IconButton(
              tooltip: 'Disconnect',
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ConnectPage())),
              icon: const Icon(Icons.logout))
        ]),
        body: IndexedStack(index: tab, children: [
          AlertsPage(
              api: widget.api,
              onChanged: refreshUnread,
              onJobs: () => setState(() => tab = 1)),
          JobsPage(api: widget.api),
          AssistantPage(api: widget.api)
        ]),
        bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: [
              NavigationDestination(
                  icon: _BadgeIcon(
                      count: unread, icon: Icons.notifications_outlined),
                  label: 'Alerts'),
              const NavigationDestination(
                  icon: Icon(Icons.work_outline), label: 'Jobs'),
              const NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined), label: 'Assistant')
            ]),
      );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Tomo logo',
        image: true,
        child: SvgPicture.asset(
          'assets/brand/tomo-logo.svg',
          width: 38,
          height: 38,
          fit: BoxFit.contain,
        ),
      );
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.count, required this.icon});
  final int count;
  final IconData icon;
  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [
        Icon(icon),
        if (count > 0)
          Positioned(
              right: -9,
              top: -7,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints:
                      const BoxConstraints(minWidth: 17, minHeight: 17),
                  decoration: const BoxDecoration(
                      color: brand, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))))
      ]);
}

class AlertsPage extends StatefulWidget {
  const AlertsPage(
      {super.key,
      required this.api,
      required this.onChanged,
      required this.onJobs});
  final TomoApi api;
  final VoidCallback onChanged, onJobs;
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<TomoNotification>> future = widget.api.getNotifications();
  void reload() => setState(() => future = widget.api.getNotifications());
  Future<void> markAll() async {
    await widget.api.markAllNotificationsRead();
    reload();
    widget.onChanged();
  }

  Future<void> tap(TomoNotification n) async {
    if (!n.isRead) {
      await widget.api.markNotificationRead(n.id);
      reload();
      widget.onChanged();
    }
    if (n.relatedJobIds.isNotEmpty) widget.onJobs();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<TomoNotification>>(
      future: future,
      builder: (context, snap) => RefreshIndicator(
          onRefresh: () async {
            reload();
            await future;
          },
          child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                const Eyebrow('YOUR TOMO UPDATES'),
                const SizedBox(height: 6),
                Row(children: [
                  const Expanded(
                      child: Text('Alerts',
                          style: TextStyle(
                              color: ink,
                              fontSize: 27,
                              fontWeight: FontWeight.w800))),
                  if ((snap.data?.any((n) => !n.isRead) ?? false))
                    TextButton(
                        onPressed: markAll, child: const Text('Mark all read'))
                ]),
                const SizedBox(height: 4),
                const Text(
                    'Fresh job lists and important updates from your account.',
                    style: TextStyle(color: muted)),
                const SizedBox(height: 20),
                if (snap.hasError)
                  ErrorPanel(message: '${snap.error}', onRetry: reload)
                else if (!snap.hasData)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(36),
                          child: CircularProgressIndicator()))
                else if (snap.data!.isEmpty)
                  const EmptyPanel(
                      icon: Icons.notifications_none,
                      title: 'You’re all caught up',
                      message:
                          'When Tomo finds new jobs, you’ll see them here.')
                else
                  ...snap.data!.map((n) =>
                      NotificationCard(notification: n, onTap: () => tap(n)))
              ])));
}

class NotificationCard extends StatelessWidget {
  const NotificationCard(
      {super.key, required this.notification, required this.onTap});
  final TomoNotification notification;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final fresh = notification.type.toUpperCase().contains('JOB');
    return Card(
        color: notification.isRead ? Colors.white : aquaSoft,
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundColor: aquaSoft,
                          child: Icon(
                              fresh
                                  ? Icons.work_outline
                                  : Icons.notifications_none,
                              color: const Color(0xFF397C74))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Expanded(
                                  child: Text(notification.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: ink))),
                              if (!notification.isRead)
                                Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: brand, shape: BoxShape.circle))
                            ]),
                            const SizedBox(height: 5),
                            Text(notification.message,
                                style:
                                    const TextStyle(color: muted, height: 1.4)),
                            if (notification.relatedJobIds.isNotEmpty)
                              const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text('View matching jobs  →',
                                      style: TextStyle(
                                          color: const Color(0xFF397C74),
                                          fontWeight: FontWeight.w700))),
                            const SizedBox(height: 7),
                            Text(_date(notification.createdAt),
                                style:
                                    const TextStyle(color: muted, fontSize: 11))
                          ]))
                    ]))));
  }
}

class JobsPage extends StatefulWidget {
  const JobsPage({super.key, required this.api});
  final TomoApi api;
  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late Future<List<JobListing>> future = widget.api.getJobs();
  String query = '';
  void reload() => setState(() => future = widget.api.getJobs());
  @override
  Widget build(BuildContext context) => FutureBuilder<List<JobListing>>(
      future: future,
      builder: (context, snap) {
        final jobs = (snap.data ?? [])
            .where((job) =>
                '${job.title} ${job.employer} ${job.location} ${job.skills}'
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
        return RefreshIndicator(
            onRefresh: () async {
              reload();
              await future;
            },
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                children: [
                  const Eyebrow('FRESH OPPORTUNITIES'),
                  const SizedBox(height: 6),
                  const Text('Find your next job',
                      style: TextStyle(
                          color: ink,
                          fontSize: 27,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  TextField(
                      onChanged: (v) => setState(() => query = v),
                      decoration: InputDecoration(
                          hintText: 'Role, skill, or location',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none))),
                  const SizedBox(height: 14),
                  if (snap.hasError)
                    ErrorPanel(message: '${snap.error}', onRetry: reload)
                  else if (!snap.hasData)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(36),
                            child: CircularProgressIndicator()))
                  else if (jobs.isEmpty)
                    const EmptyPanel(
                        icon: Icons.work_outline,
                        title: 'No jobs found',
                        message:
                            'Try another search, or check back after the next job search.')
                  else
                    ...jobs.map((job) => JobCard(
                        job: job,
                        onTap: () => showJobDetails(context, widget.api, job)))
                ]));
      });
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onTap});
  final JobListing job;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                                  job.title.isEmpty
                                      ? 'Untitled role'
                                      : job.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: ink))),
                          if (job.isRemote)
                            const Chip(
                                label: Text('Remote'),
                                visualDensity: VisualDensity.compact)
                        ]),
                    const SizedBox(height: 5),
                    Text(job.employer, style: const TextStyle(color: muted)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: muted),
                      const SizedBox(width: 3),
                      Expanded(
                          child: Text(
                              job.location.isEmpty
                                  ? 'Location not listed'
                                  : job.location,
                              style:
                                  const TextStyle(color: muted, fontSize: 13))),
                      if (job.payRange.isNotEmpty)
                        Text(job.payRange,
                            style: const TextStyle(
                                color: const Color(0xFF397C74),
                                fontWeight: FontWeight.w700,
                                fontSize: 12))
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      if (job.employmentType.isNotEmpty)
                        _Tag(job.employmentType),
                      const Spacer(),
                      const Text('View details  →',
                          style: TextStyle(
                              color: const Color(0xFF397C74),
                              fontWeight: FontWeight.w700,
                              fontSize: 12))
                    ])
                  ]))));
}

Future<void> showJobDetails(
    BuildContext context, TomoApi api, JobListing job) async {
  await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    const SizedBox(height: 6),
                    Text('${job.employer} · ${job.location}',
                        style: const TextStyle(color: muted)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 7, children: [
                      if (job.employmentType.isNotEmpty)
                        _Tag(job.employmentType),
                      if (job.shift.isNotEmpty) _Tag(job.shift),
                      if (job.payRange.isNotEmpty) _Tag(job.payRange),
                      if (job.isRemote) const _Tag('Remote')
                    ]),
                    const SizedBox(height: 18),
                    const Text('About the role',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    SelectableText(
                        job.description.isEmpty
                            ? 'No description available.'
                            : job.description,
                        style: const TextStyle(color: muted, height: 1.55)),
                    if (job.skills.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text('Skills',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(job.skills, style: const TextStyle(color: muted))
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                            onPressed: job.applyLink.isEmpty
                                ? null
                                : () async {
                                    final uri = Uri.tryParse(job.applyLink);
                                    if (uri != null &&
                                        await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'No application link is available for this job.')));
                                    }
                                  },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Apply for this job')))
                  ])))));
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key, required this.api});
  final TomoApi api;
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final messages = <_ChatMessage>[];
  int? conversationId;
  bool sending = false;
  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending) return;
    input.clear();
    setState(() {
      messages.add(_ChatMessage(text, true));
      sending = true;
    });
    _scrollDown();
    try {
      final reply = await widget.api.sendAssistantMessage(text, conversationId);
      conversationId = reply.conversationId;
      setState(() => messages
          .add(_ChatMessage(reply.answer, false, sources: reply.sources)));
    } on TomoApiException catch (e) {
      setState(() => messages.add(_ChatMessage(
          'I couldn’t reach the Tomo assistant: ${e.message}', false)));
    } finally {
      if (mounted) {
        setState(() => sending = false);
        _scrollDown();
      }
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(children: [
              const CircleAvatar(
                  backgroundColor: aquaSoft,
                  child: Icon(Icons.auto_awesome, color: Color(0xFF397C74))),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Your personal assistant',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    Text('Ask about jobs, applications, or your next steps.',
                        style: TextStyle(color: muted, fontSize: 12))
                  ]))
            ])),
        Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: EmptyPanel(
                        icon: Icons.chat_bubble_outline,
                        title: 'How can I help?',
                        message:
                            'Ask me to find roles that fit your skills or help you prepare an application.'))
                : ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: messages.length + (sending ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= messages.length) {
                        return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator()));
                      }
                      final m = messages[i];
                      return Align(
                          alignment: m.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                              constraints: const BoxConstraints(maxWidth: 330),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                  color: m.user ? ink : Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.text,
                                        style: TextStyle(
                                            color: m.user ? Colors.white : ink,
                                            height: 1.45)),
                                    if (m.sources.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text('Sources: ${m.sources.join(', ')}',
                                          style: TextStyle(
                                              color: m.user
                                                  ? Colors.white70
                                                  : muted,
                                              fontSize: 11))
                                    ]
                                  ])));
                    })),
        SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: input,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => send(),
                          decoration: InputDecoration(
                              hintText: 'Message your assistant…',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12)))),
                  const SizedBox(width: 8),
                  IconButton.filled(
                      onPressed: sending ? null : send,
                      icon: const Icon(Icons.arrow_upward))
                ])))
      ]);
}

class _ChatMessage {
  const _ChatMessage(this.text, this.user, {this.sources = const []});
  final String text;
  final bool user;
  final List<String> sources;
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero);
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 18),
      child: Column(children: [
        Icon(icon, size: 38, color: brand),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.4))
      ]));
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(message, style: const TextStyle(color: muted)),
        TextButton(onPressed: onRetry, child: const Text('Try again'))
      ]);
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1.2));
}

String _date(DateTime? value) {
  if (value == null) return 'Just now';
  final now = DateTime.now();
  final d = now.difference(value);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return '${value.day}/${value.month}/${value.year}';
}
