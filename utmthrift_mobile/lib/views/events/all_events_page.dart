import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'event_details_page.dart';

class AllEventsPage extends StatelessWidget {
  const AllEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EventViewModel>(context, listen: false);
    vm.fetchAllEvents();

    return Scaffold(
      appBar: AppBar(title: const Text("All Events")),
      body: Consumer<EventViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: vm.allEvents.length,
            itemBuilder: (context, index) {
              final event = vm.allEvents[index];
              return ListTile(
                leading: Image.network(event.poster, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(event.title),
                subtitle: Text(event.eventDate),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => EventDetailsPage(event: event, imagePath: '',),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
