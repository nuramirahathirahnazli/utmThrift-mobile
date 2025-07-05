import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'package:utmthrift_mobile/views/events/event_details_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      Provider.of<EventViewModel>(context, listen: false).fetchAllEvents();
      _hasFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "All Events",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: Consumer<EventViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color2,
              ),
            );
          }

          if (vm.allEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: AppColors.color10.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No events available",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.color10.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: vm.allEvents.length,
              itemBuilder: (context, index) {
                final event = vm.allEvents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsPage(
                          event: event,
                          imagePath: '',
                        ),
                      ),
                    );
                  },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'event-image-${event.id}',
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.color12,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: event.fullPosterUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      event.fullPosterUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: AppColors.color3,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.event,
                                      size: 50,
                                      color: AppColors.color10.withOpacity(0.3),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.color10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}