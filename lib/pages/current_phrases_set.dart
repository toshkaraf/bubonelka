import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/const_parameters.dart';

class CurrentPhrasesSet {
  static CurrentPhrasesSet? _instance;
  Map<String, List<PhraseCard>> totalCollection =
      CollectionProvider.getInstance().totalCollection;
  List<String> _chosenThemes = [];
  PhraseCard currentPhraseCard = emptyPhraseCard;
  int themeCaunter = 0;
  int phraseCardsCounter = -1;

  CurrentPhrasesSet._();

  static CurrentPhrasesSet getInstance() {
    _instance ??= CurrentPhrasesSet._();
    return _instance!;
  }

  List<String> get chosenThemes => _chosenThemes;

  set chosenThemes(List<String> themes) {
    _chosenThemes = themes;
  }

  PhraseCard getNextPhraseCard() {
    if (themeCaunter < chosenThemes.length &&
        totalCollection[_chosenThemes[themeCaunter]] != null) {
      if (phraseCardsCounter <
          totalCollection[_chosenThemes[themeCaunter]]!.length) {
        phraseCardsCounter++;
        return totalCollection[_chosenThemes[themeCaunter]]![
            phraseCardsCounter];
      } else {
        themeCaunter++;
        phraseCardsCounter = 0;
        return totalCollection[_chosenThemes[themeCaunter]]![
            phraseCardsCounter];
      }
    } else {
      chosenThemes = [];
      return emptyPhraseCard;
    }
  }

  PhraseCard getPreviousPhraseCard() {
    if (themeCaunter > 0 &&
        totalCollection[_chosenThemes[themeCaunter]] != null) {
      if (phraseCardsCounter > 1) {
        phraseCardsCounter--;
        return totalCollection[_chosenThemes[themeCaunter]]![
            phraseCardsCounter];
      } else {
        themeCaunter--;
        phraseCardsCounter = 0;
        return totalCollection[_chosenThemes[themeCaunter]]![
            phraseCardsCounter];
      }
    } else {
      themeCaunter = 0;
      phraseCardsCounter = 1;
      return totalCollection[_chosenThemes[themeCaunter]]![phraseCardsCounter];
    }
  }
}
