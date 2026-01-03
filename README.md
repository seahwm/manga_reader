# manga_reader

A manga reader application written in Flutter.

## Structure
the comic folder need to be in following Structure:
- Mange1
  - index.jpg (for cover page)
  - Chapter 1
    - 1.jpg
    - 2.jpg
  - Chapter 2
    - 1.jpg
    - 2.jpg
    - ...
- Manga2
  - index.jpg (for cover page)
  - Chapter 1
      - 1.jpg
      - 2.jpg
  - Chapter 2
      - 1.jpg
      - 2.jpg
      - ...
- ...
## TODO:

- [ ] page memory/ manga history (maybe)
    - When go out, from chapter 1 at page 12, whn back will direct navigate to page 12. Maybe only used for single volume, but disable for single chapter.
    - Record down the last read chapter
- [ ] epub reader for light novel (maybe)
- [ ] horizontally scrollable chapters (maybe)
- [ ] page counter at right bottom (maybe)
- [ ] Setting page
  - [ ] margin setting in case too near screen and unbale see clearly due to phone case
  - [ ] dark mode maybe
- [ ] db management
  - [ ] clear db record for certain manga only instead of delete all record
  - [ ] sql browser to view all record/table, and enable user to execute sql script (maybe)
- [ ] Code refactoring, now very messy
