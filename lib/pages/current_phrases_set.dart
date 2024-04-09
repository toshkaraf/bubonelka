import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/const_parameters.dart';

class CurrentPhrasesSet {
  Map<String, List<PhraseCard>> totalCollection;
  List<String> _chosenThemes = CollectionProvider.getInstance().chosenThemes;

  PhraseCard currentPhraseCard = emptyPhraseCard;
  int themeCounter = 0;
  int phraseCardsCounter = -1;

  CurrentPhrasesSet()
      : totalCollection = CollectionProvider.getInstance().getTotalCollection();

  List<String> get chosenThemes => _chosenThemes;

  set chosenThemes(List<String> themes) {
    _chosenThemes = themes;
  }

  PhraseCard getNextPhraseCard() {
    if (themeCounter <= _chosenThemes.length - 1 &&
        totalCollection[_chosenThemes[themeCounter]] != null) {
      if (phraseCardsCounter <
          totalCollection[_chosenThemes[themeCounter]]!.length - 1) {
        phraseCardsCounter++;
        currentPhraseCard =
            totalCollection[_chosenThemes[themeCounter]]![phraseCardsCounter];
        if (!currentPhraseCard.isActive) getNextPhraseCard();
        currentPhraseCard.printPhraseCard();
        print(_chosenThemes[themeCounter]);
        return currentPhraseCard;
      } else if (themeCounter != _chosenThemes.length - 1) {
        CollectionProvider.getInstance()
            .upgradeStatisticForTheme(_chosenThemes[themeCounter]);
        themeCounter++;
        phraseCardsCounter = 0;
        currentPhraseCard =
            totalCollection[_chosenThemes[themeCounter]]![phraseCardsCounter];
        if (!currentPhraseCard.isActive) getNextPhraseCard();
        print(_chosenThemes[themeCounter]);
        currentPhraseCard.printPhraseCard();
        return currentPhraseCard;
      } else {
        CollectionProvider.getInstance()
            .upgradeStatisticForTheme(_chosenThemes[themeCounter]);
        currentPhraseCard = emptyPhraseCard;
        currentPhraseCard.printPhraseCard();
        return currentPhraseCard;
      }
    } else {
      currentPhraseCard = emptyPhraseCard;
      currentPhraseCard.printPhraseCard();
      return currentPhraseCard;
    }
  }

  PhraseCard getPreviousPhraseCard() {
    if (themeCounter >= 0 &&
        totalCollection[_chosenThemes[themeCounter]] != null) {
      if (phraseCardsCounter > 1) {
        phraseCardsCounter--;
        currentPhraseCard =
            totalCollection[_chosenThemes[themeCounter]]![phraseCardsCounter];
        if (!currentPhraseCard.isActive) getNextPhraseCard();
        return currentPhraseCard;
      } else if (themeCounter != 0) {
        themeCounter--;
        phraseCardsCounter =
            totalCollection[_chosenThemes[themeCounter]]!.length - 1;
        currentPhraseCard =
            totalCollection[_chosenThemes[themeCounter]]![phraseCardsCounter];
        if (!currentPhraseCard.isActive) getNextPhraseCard();
        return currentPhraseCard;
      } else {
        themeCounter = 0;
        phraseCardsCounter = 0;
        return totalCollection[_chosenThemes[themeCounter]]![
            phraseCardsCounter];
      }
    } else {
      themeCounter = 0;
      phraseCardsCounter = 0;
      return totalCollection[_chosenThemes[themeCounter]]![phraseCardsCounter];
    }
  }
}
