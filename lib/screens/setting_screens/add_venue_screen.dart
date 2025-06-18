// AddVenueScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/setting_screens_providers/venue_provider.dart';
import '../../widgets/textfield _editprofiile.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  @override
  Widget build(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Add Venue'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_sharp)),
      ),
      body: venueProvider.isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => venueProvider.pickImage(context),
              child: Consumer<VenueProvider>(
                builder: (context, provider, child) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.pink[400]!, width: 1),
                      image: provider.pickedVenueImage != null
                          ? DecorationImage(
                        image:
                        FileImage(provider.pickedVenueImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: provider.pickedVenueImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Colors.pink[400],
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to Add Venue Image',
                          style: TextStyle(
                            color: Colors.pink[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            TextfieldEditprofiile(
              controller: venueProvider.venuenameController,
              hintText: 'Enter venue name',
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: venueProvider.addressController,
              hintText: 'Enter Address details',
              prefixIcon: Icons.location_city,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Choose Location Option',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.my_location,
                                color: Colors.pink),
                            title: const Text(
                              "Use Current Location",
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await venueProvider
                                  .getCurrentLocation(context);
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.edit_location_alt,
                                color: Colors.deepPurple),
                            title: const Text(
                              "Enter Location Manually",
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              venueProvider
                                  .showManualLocationPicker(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Consumer<VenueProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1, color: Colors.pink.shade400),
                    ),
                    child: Row(
                      children: [
                         Icon(Icons.location_on,
                            color: Colors.pink, size: 24,),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (provider.selectedLocation?.isNotEmpty ??
                                    false)
                                    ? provider.selectedLocation!
                                    : 'Select Venue Location',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Tap to choose from map or enter manually',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: venueProvider.cityController,
              hintText: 'Enter city',
              prefixIcon: Icons.location_pin,
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: venueProvider.descriptionController,
              hintText: 'Enter venue description',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Select Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            Consumer<VenueProvider>(
              builder: (context, provider, _) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.pink.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.availableFacilities.map((facility) {
                      final isSelected = provider.selectedFacilities.contains(facility);
                      return FilterChip(
                        selected: isSelected,
                        selectedColor: Colors.pink,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,

                        // 👇 A stacked name + description as the chip’s label
                        label: Text(
                          facility,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                        ),

                        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

                        onSelected: (selected) {
                          if (selected) {
                            provider.selectedFacilities.add(facility);
                          } else {
                            provider.selectedFacilities.remove(facility);
                          }
                          provider.notifyListeners();
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => venueProvider.addVenue(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Venue',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
