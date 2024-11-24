import 'package:cloud_firestore/cloud_firestore.dart';

class Psychotherapist {
  final String name;
  final String specialization;
  final String contact;
  final String email;
  final String address;

  Psychotherapist({
    required this.name,
    required this.specialization,
    required this.contact,
    required this.email,
    required this.address,
  });

  // Convert Psychotherapist object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'contact': contact,
      'email': email,
      'address': address,
    };
  }
}

void addPsychotherapist(Psychotherapist psychotherapist) async {
  try {
    // Reference to the 'psychotherapists' collection
    CollectionReference<Map<String, dynamic>> therapistsCollection =
        FirebaseFirestore.instance.collection('psychotherapists');

    // Add a new document with a generated ID
    await therapistsCollection.add(psychotherapist.toMap());

    print('Psychotherapist added successfully!');
  } catch (e) {
    print('Error adding psychotherapist: $e');
  }
}

void main() {
  // Example 1
  Psychotherapist therapist1 = Psychotherapist(
    name: 'Dr. Amina Ben Ali',
    specialization: 'Cognitive Behavioral Therapy',
    contact: '987-654-3210',
    email: 'amina.benali@example.com',
    address: '456 Oak Avenue, Tunis',
  );
  addPsychotherapist(therapist1);

  // Example 2
  Psychotherapist therapist2 = Psychotherapist(
    name: 'Dr. Ahmed Khelifi',
    specialization: 'Family Therapy',
    contact: '555-123-4567',
    email: 'ahmed.khelifi@example.com',
    address: '789 Pine Street, Sidi Bou Said',
  );
  addPsychotherapist(therapist2);

  // Example 3
  Psychotherapist therapist3 = Psychotherapist(
    name: 'Dr. Leila Gharbi',
    specialization: 'Art Therapy',
    contact: '333-999-8888',
    email: 'leila.gharbi@example.com',
    address: '101 Maple Lane, Carthage',
  );
  addPsychotherapist(therapist3);

  // Example 4
  Psychotherapist therapist4 = Psychotherapist(
    name: 'Dr. Noura Jlassi',
    specialization: 'Narrative Therapy',
    contact: '555-666-7777',
    email: 'noura.jlassi@example.com',
    address: '321 Pine Lane, Bizerte',
  );
  addPsychotherapist(therapist4);

  // Example 5
  Psychotherapist therapist5 = Psychotherapist(
    name: 'Dr. Hichem Bouazizi',
    specialization: 'Existential Therapy',
    contact: '222-333-4444',
    email: 'hichem.bouazizi@example.com',
    address: '987 Cypress Street, Monastir',
  );
  addPsychotherapist(therapist5);

  // Example 6
  Psychotherapist therapist6 = Psychotherapist(
    name: 'Dr. Amira Chaabane',
    specialization: 'Art Therapy',
    contact: '999-000-1111',
    email: 'amira.chaabane@example.com',
    address: '654 Cedar Lane, Kairouan',
  );
  addPsychotherapist(therapist6);

  // Example 7
  Psychotherapist therapist7 = Psychotherapist(
    name: 'Dr. Samiha Belhaj',
    specialization: 'Behavioral Therapy',
    contact: '333-444-5555',
    email: 'samiha.belhaj@example.com',
    address: '789 Olive Avenue, Gabès',
  );
  addPsychotherapist(therapist7);

  // Example 8
  Psychotherapist therapist8 = Psychotherapist(
    name: 'Dr. Rafik Toumi',
    specialization: 'Cognitive Therapy',
    contact: '666-777-8888',
    email: 'rafik.toumi@example.com',
    address: '543 Maple Street, Nabeul',
  );
  addPsychotherapist(therapist8);

  // Example 9
  Psychotherapist therapist9 = Psychotherapist(
    name: 'Dr. Sarra Ben Amor',
    specialization: 'Solution-Focused Therapy',
    contact: '444-555-6666',
    email: 'sarra.benamor@example.com',
    address: '876 Palm Avenue, Djerba',
  );
  addPsychotherapist(therapist9);

  // Example 10
  Psychotherapist therapist10 = Psychotherapist(
    name: 'Dr. Fathi Mzoughi',
    specialization: 'Trauma Therapy',
    contact: '111-222-3333',
    email: 'fathi.mzoughi@example.com',
    address: '321 Cedar Lane, Tozeur',
  );
  addPsychotherapist(therapist10);
}
