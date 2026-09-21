import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final PackioStore store;

  const SplashScreen({super.key, required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 40));
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PackioMark(size: 98),
            SizedBox(height: 22),
            Text(
              'PACKIO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'PACK SMART • TRAVEL READY',
              style: TextStyle(
                color: terracotta,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final PackioStore store;

  const HomeScreen({super.key, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final q = search.trim().toLowerCase();
        final trips = widget.store.trips.where((trip) {
          if (q.isEmpty) return true;
          return trip.title.toLowerCase().contains(q) ||
              trip.destination.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              children: [
                Row(
                  children: [
                    const PackioMark(size: 54),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PACKIO',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.2,
                            ),
                          ),
                          Text(
                            'YOUR TRAVEL JOURNAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Statistics',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatsScreen(store: widget.store),
                        ),
                      ),
                      icon: const Icon(Icons.insights_rounded),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: widget.store),
                        ),
                      ),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextField(
                  onChanged: (value) => setState(() => search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search trips or destinations',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 22),
                _NextTripCard(
                  store: widget.store,
                  trip: widget.store.nextTrip,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your trips',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _createTrip,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('NEW'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (trips.isEmpty)
                  _EmptyTrips(onCreate: _createTrip)
                else
                  ...trips.map(
                    (trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TripTicket(
                        trip: trip,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripDetailScreen(
                              store: widget.store,
                              tripId: trip.id,
                            ),
                          ),
                        ),
                        onDuplicate: () => widget.store.duplicateTrip(trip),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: terracotta,
            foregroundColor: Colors.white,
            onPressed: _createTrip,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New trip'),
          ),
        );
      },
    );
  }

  Future<void> _createTrip() async {
    final trip = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(
        builder: (_) => const TripEditorScreen(),
      ),
    );

    if (trip != null) {
      await widget.store.addTrip(trip);
    }
  }
}

class _NextTripCard extends StatelessWidget {
  final PackioStore store;
  final Trip? trip;

  const _NextTripCard({
    required this.store,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    if (trip == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'READY FOR THE NEXT ONE?',
              style: TextStyle(
                color: Color(0xFFDDEDE3),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 9),
            Text(
              'No upcoming trip yet.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Create a trip and build a packing list that stays with you.',
              style: TextStyle(color: Color(0xFFE5F0E9), height: 1.45),
            ),
          ],
        ),
      );
    }

    final total = trip!.items.length;
    final packed = trip!.items.where((e) => e.packed).length;
    final progress = total == 0 ? 0.0 : packed / total;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripDetailScreen(
            store: store,
            tripId: trip!.id,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXT TRIP',
                    style: TextStyle(
                      color: Color(0xFFDDEDE3),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip!.destination.isEmpty
                        ? dateRange(trip!)
                        : '${trip!.destination} • ${dateRange(trip!)}',
                    style: const TextStyle(
                      color: Color(0xFFE5F0E9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    '$packed of $total packed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(.14),
                    color: sand,
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripTicket extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;

  const _TripTicket({
    required this.trip,
    required this.onTap,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final total = trip.items.length;
    final packed = trip.items.where((e) => e.packed).length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 72,
                decoration: BoxDecoration(
                  color: terracotta.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.airplane_ticket_rounded,
                  color: terracotta,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trip.destination.isEmpty
                          ? dateRange(trip)
                          : '${trip.destination} • ${dateRange(trip)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$packed / $total packed',
                      style: const TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'duplicate') onDuplicate();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicate trip'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyTrips({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(
              Icons.backpack_outlined,
              size: 50,
              color: terracotta,
            ),
            const SizedBox(height: 14),
            const Text(
              'Your travel journal is empty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a trip, add a packing list, and track what is ready.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create first trip'),
            ),
          ],
        ),
      ),
    );
  }
}


class TripEditorScreen extends StatefulWidget {
  final Trip? trip;

  const TripEditorScreen({super.key, this.trip});

  @override
  State<TripEditorScreen> createState() => _TripEditorScreenState();
}

class _TripEditorScreenState extends State<TripEditorScreen> {
  late final TextEditingController titleController;
  late final TextEditingController destinationController;
  late final TextEditingController notesController;

  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    titleController = TextEditingController(text: trip?.title ?? '');
    destinationController = TextEditingController(text: trip?.destination ?? '');
    notesController = TextEditingController(text: trip?.notes ?? '');
    startDate = trip?.startDate ?? DateTime.now();
    endDate = trip?.endDate ?? DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    titleController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.trip != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'EDIT TRIP' : 'NEW TRIP'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Trip details',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Keep the plan simple. You can build the packing list next.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: titleController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Trip name',
              prefixIcon: Icon(Icons.luggage_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destinationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Destination',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'START',
                  date: startDate,
                  onTap: _pickStart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'END',
                  date: endDate,
                  onTap: _pickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Trip notes',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(editing ? 'SAVE CHANGES' : 'CREATE TRIP'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      startDate = picked;
      if (endDate.isBefore(startDate)) {
        endDate = startDate;
      }
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.isBefore(startDate) ? startDate : endDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => endDate = picked);
  }

  void _save() {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a trip name first.')),
      );
      return;
    }

    final original = widget.trip;
    final trip = Trip(
      id: original?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      destination: destinationController.text.trim(),
      startDate: startDate,
      endDate: endDate,
      notes: notesController.text.trim(),
      items: original?.items ?? [],
      createdAt: original?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, trip);
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: terracotta,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                dateLabel(date),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripDetailScreen extends StatelessWidget {
  final PackioStore store;
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.store,
    required this.tripId,
  });

  Trip? _trip() {
    for (final trip in store.trips) {
      if (trip.id == tripId) return trip;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final trip = _trip();

        if (trip == null) {
          return const Scaffold(
            body: Center(child: Text('Trip not found')),
          );
        }

        final total = trip.items.length;
        final packed = trip.items.where((e) => e.packed).length;
        final progress = total == 0 ? 0.0 : packed / total;

        return Scaffold(
          appBar: AppBar(
            title: const Text('PACKING BOARD'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenu(context, trip, value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit trip')),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicate trip'),
                  ),
                  PopupMenuItem(value: 'delete', child: Text('Delete trip')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: forest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      trip.destination.isEmpty
                          ? dateRange(trip)
                          : '${trip.destination} • ${dateRange(trip)}',
                      style: const TextStyle(
                        color: Color(0xFFE5F0E9),
                      ),
                    ),
                    const SizedBox(height: 18),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: Colors.white.withOpacity(.16),
                      color: sand,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$packed of $total packed • ${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (trip.notes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          color: terracotta,
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: Text(trip.notes)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Packing list',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showTemplates(context, trip),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('TEMPLATES'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (trip.items.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: terracotta,
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nothing to pack yet.',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add items manually or start from a ready-made template.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...packingCategories.map((category) {
                  final items = trip.items
                      .where((e) => e.category == category)
                      .toList();

                  if (items.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CategorySection(
                      store: store,
                      trip: trip,
                      category: category,
                      items: items,
                    ),
                  );
                }),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: terracotta,
            foregroundColor: Colors.white,
            onPressed: () => _addItem(context, trip),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add item'),
          ),
        );
      },
    );
  }

  Future<void> _handleMenu(
    BuildContext context,
    Trip trip,
    String value,
  ) async {
    if (value == 'edit') {
      final updated = await Navigator.push<Trip>(
        context,
        MaterialPageRoute(
          builder: (_) => TripEditorScreen(trip: trip),
        ),
      );

      if (updated != null) {
        await store.updateTrip(updated);
      }
      return;
    }

    if (value == 'duplicate') {
      await store.duplicateTrip(trip);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this trip?'),
        content: const Text(
          'The trip and its packing list will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await store.deleteTrip(trip.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _addItem(BuildContext context, Trip trip) async {
    final item = await showDialog<PackItem>(
      context: context,
      builder: (_) => const ItemEditorDialog(),
    );

    if (item != null) {
      await store.addItem(trip, item);
    }
  }

  Future<void> _showTemplates(BuildContext context, Trip trip) async {
    final template = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ready-made templates',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.weekend_outlined),
                title: const Text('Weekend trip'),
                subtitle: const Text('Light clothes, toiletries, charger, ID'),
                onTap: () => Navigator.pop(sheetContext, 'weekend'),
              ),
              ListTile(
                leading: const Icon(Icons.work_outline_rounded),
                title: const Text('Business trip'),
                subtitle: const Text('Work gear, documents, formal clothes'),
                onTap: () => Navigator.pop(sheetContext, 'business'),
              ),
              ListTile(
                leading: const Icon(Icons.beach_access_outlined),
                title: const Text('Beach trip'),
                subtitle: const Text('Swimwear, sunscreen, towel, sunglasses'),
                onTap: () => Navigator.pop(sheetContext, 'beach'),
              ),
            ],
          ),
        ),
      ),
    );

    if (template == null) return;

    for (final item in _templateItems(template)) {
      await store.addItem(trip, item);
    }
  }

  List<PackItem> _templateItems(String type) {
    final data = <Map<String, String>>[];

    if (type == 'weekend') {
      data.addAll([
        {'name': 'T-shirts', 'category': 'Clothes'},
        {'name': 'Underwear', 'category': 'Clothes'},
        {'name': 'Toothbrush', 'category': 'Toiletries'},
        {'name': 'Phone charger', 'category': 'Electronics'},
        {'name': 'ID / Passport', 'category': 'Documents'},
      ]);
    } else if (type == 'business') {
      data.addAll([
        {'name': 'Formal outfit', 'category': 'Clothes'},
        {'name': 'Laptop', 'category': 'Work'},
        {'name': 'Laptop charger', 'category': 'Electronics'},
        {'name': 'Business documents', 'category': 'Documents'},
        {'name': 'Notebook', 'category': 'Work'},
      ]);
    } else {
      data.addAll([
        {'name': 'Swimwear', 'category': 'Clothes'},
        {'name': 'Sunscreen', 'category': 'Toiletries'},
        {'name': 'Beach towel', 'category': 'Other'},
        {'name': 'Sunglasses', 'category': 'Other'},
        {'name': 'Phone charger', 'category': 'Electronics'},
      ]);
    }

    final now = DateTime.now().microsecondsSinceEpoch;

    return List.generate(
      data.length,
      (index) => PackItem(
        id: '${now}_$index',
        name: data[index]['name']!,
        category: data[index]['category']!,
        quantity: 1,
        packed: false,
        essential: data[index]['category'] == 'Documents',
        notes: '',
      ),
    );
  }
}


class _CategorySection extends StatelessWidget {
  final PackioStore store;
  final Trip trip;
  final String category;
  final List<PackItem> items;

  const _CategorySection({
    required this.store,
    required this.trip,
    required this.category,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final packed = items.where((e) => e.packed).length;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: forest.withOpacity(.10),
          child: Icon(categoryIcon(category), color: forest),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('$packed / ${items.length} packed'),
        children: items
            .map(
              (item) => _PackingRow(
                store: store,
                trip: trip,
                item: item,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PackingRow extends StatelessWidget {
  final PackioStore store;
  final Trip trip;
  final PackItem item;

  const _PackingRow({
    required this.store,
    required this.trip,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => store.togglePacked(trip, item),
      leading: Checkbox(
        value: item.packed,
        activeColor: forest,
        onChanged: (_) => store.togglePacked(trip, item),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: item.essential ? FontWeight.w900 : FontWeight.w700,
          decoration: item.packed ? TextDecoration.lineThrough : null,
          color: item.packed
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : null,
        ),
      ),
      subtitle: (item.quantity > 1 || item.notes.isNotEmpty)
          ? Text(
              [
                if (item.quantity > 1) 'Qty ${item.quantity}',
                if (item.notes.isNotEmpty) item.notes,
              ].join(' • '),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.essential)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.priority_high_rounded,
                color: terracotta,
                size: 20,
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _menu(context, value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit item')),
              PopupMenuItem(value: 'delete', child: Text('Delete item')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _menu(BuildContext context, String value) async {
    if (value == 'delete') {
      await store.deleteItem(trip, item.id);
      return;
    }

    final updated = await showDialog<PackItem>(
      context: context,
      builder: (_) => ItemEditorDialog(item: item),
    );

    if (updated != null) {
      await store.updateItem(trip, updated);
    }
  }
}

class ItemEditorDialog extends StatefulWidget {
  final PackItem? item;

  const ItemEditorDialog({super.key, this.item});

  @override
  State<ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  late String name;
  late String category;
  late int quantity;
  late bool essential;
  late String notes;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    name = item?.name ?? '';
    category = item?.category ?? 'Clothes';
    quantity = item?.quantity ?? 1;
    essential = item?.essential ?? false;
    notes = item?.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null ? 'Add packing item' : 'Edit packing item',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => name = value,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category,
              items: packingCategories
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: quantity,
              items: List.generate(
                10,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Quantity ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) setState(() => quantity = value);
              },
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: notes,
              onChanged: (value) => notes = value,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: essential,
              onChanged: (value) => setState(() => essential = value),
              title: const Text('Essential item'),
              subtitle: const Text('Highlight this item as important'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _save() {
    final clean = name.trim();
    if (clean.isEmpty) return;

    Navigator.pop(
      context,
      PackItem(
        id: widget.item?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        name: clean,
        category: category,
        quantity: quantity,
        packed: widget.item?.packed ?? false,
        essential: essential,
        notes: notes.trim(),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  final PackioStore store;

  const StatsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final progress = store.totalItems == 0
            ? 0.0
            : store.packedItems / store.totalItems;

        return Scaffold(
          appBar: AppBar(title: const Text('TRAVEL STATS')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Packing overview',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'A simple look at your trips and packing progress.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${store.trips.length}',
                      label: 'TRIPS',
                      icon: Icons.flight_takeoff_rounded,
                      color: terracotta,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${store.totalItems}',
                      label: 'ITEMS',
                      icon: Icons.inventory_2_outlined,
                      color: forest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${store.packedItems}',
                      label: 'PACKED',
                      icon: Icons.check_circle_outline_rounded,
                      color: forest,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${store.essentialItems}',
                      label: 'ESSENTIAL',
                      icon: Icons.priority_high_rounded,
                      color: terracotta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall packing progress',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(99),
                        color: forest,
                        backgroundColor: softGreen,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${(progress * 100).round()}% of all saved items are packed',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final PackioStore store;

  const SettingsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  textColor: terracotta,
                  iconColor: terracotta,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Reset all data'),
                  subtitle: const Text('Delete all saved trips and items.'),
                  onTap: () => _reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset PACKIO?'),
        content: const Text(
          'All trips, packing lists, and statistics will be deleted from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await store.resetAll();
    }
  }
}

const privacyText = '''PACKIO PRIVACY POLICY

PACKIO is an offline-first packing list and trip organizer.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, or cloud synchronization.

Trip names, destinations, trip dates, trip notes, packing items, categories, quantities, essential-item flags, packed status, appearance preference, and local statistics are stored on your device.

This information is used only to provide trip planning, packing lists, packing progress, templates, search, duplication, history, statistics, and settings.

The current core version does not require access to your precise location, camera, microphone, contacts, phone, SMS, calendar, photos, media, files, or payment information.

PACKIO does not intentionally sell or rent your locally stored trip information and does not use it for personalized advertising.

You can delete individual trips or reset all saved data from the app. Clearing application storage or uninstalling the app may also remove locally stored information, subject to operating-system backup and restore behavior.

If future versions add accounts, cloud sync, analytics, crash reporting, advertising, online services, payments, location features, or additional permissions, this policy should be reviewed and updated before release.

For privacy questions, contact the app publisher through the support email shown on the store listing.''';

const termsText = '''PACKIO TERMS & CONDITIONS

PACKIO is a personal packing list and trip organization tool.

The app helps you create trips, dates, packing items, categories, quantities, notes, templates, essential-item indicators, progress, and local statistics.

PACKIO does not provide travel bookings, transportation services, visa advice, medical advice, legal advice, insurance, or guarantees that a packing list is complete.

You are responsible for verifying passports, visas, medicines, tickets, reservations, safety requirements, and other important travel needs independently.

The current core version stores information locally. We do not guarantee recovery of saved data after uninstalling the app, clearing app data, device loss, storage failure, or operating-system changes.

PACKIO is provided on an "as available" basis to the extent permitted by applicable law. Features may be improved, changed, added, or removed in future versions.

Use of PACKIO is also subject to applicable laws and the terms of the app-distribution platform through which you obtained it.''';

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            body,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}
