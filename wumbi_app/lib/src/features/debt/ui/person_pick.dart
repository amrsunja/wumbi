import '../data/models/debt_intent.dart';
import '../data/models/person_model.dart';

/// Result of the person picker: an existing person, a new name to create on
/// save (find-or-create, like tags), or "no person".
sealed class PersonPick {
  const PersonPick();
}

class PickedPerson extends PersonPick {
  const PickedPerson(this.person);
  final PersonModel person;
}

class NewPerson extends PersonPick {
  const NewPerson(this.name);
  final String name;
}

class NoPerson extends PersonPick {
  const NoPerson();
}

/// The repository reference for a chosen person (id or name to create).
PersonRef personRefOf({required String? personId, required String name}) =>
    personId != null ? PersonRef.existing(personId) : PersonRef.create(name);
