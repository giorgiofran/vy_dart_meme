# Changelog vy_dart_meme

## 0.1.7

- More tests
- Fixes

## 0.1.6

- Change in the overall behavior. Now the original language (and term) are immutable. 
It is possible to add a translation also for the original language, 
the original term is not touched. Added the merge logic into MemeTerm.
Removed the added languages into MemeHeader.
Now the default language is mainly used to identify the language of the message
definition (in the annotation).

## 0.1.5

- Flavors

## 0.1.4

- Fixed error in Meme.decode()
- Fixed error in MemeTerm.fromJson()
- Fixed error in MemeProject.mergeWith()
- Added terms Iterable in MemeProject
- Fix on Meme.decode()

## 0.1.3

- Added default to be translated from language logic in MemeTerm class
- Small fix on decode() and encode() methods in Meme class
- Merge project logic
- Merge meme file

## 0.1.2

- Small fix on term resetTerm() method
- Small fix on term fromJson method()

## 0.1.1

- Lint cleanup

## 0.1.0

- Initial version, Base classes for Meme file management
