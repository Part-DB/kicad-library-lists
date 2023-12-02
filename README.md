# KiCad symbols & footprints list generator

The scripts inside this folder are used to generate the `symbols.txt` and `footprints.txt` list, which Part-DB uses to provide autocomplete on Kicad symbol and footprints fields.

The lists are created from the latest master branch of the kicad library.

**Attention**: These scripts rely heavily on regex expressions to extract the names. If KiCad changes formats, this scripts will most likely break.

## Usage

Just run `./gen_footprints_list.sh` and/or `./gen_symbols_list.sh` and the process will start. At the end you will end up with fresh lists.

## License

The scripts in this repository are licensed under the MIT license. See `LICENSE` file in this repo for more info.

The KiCad librariers, from which this lists are generated, are under CC-BY-SA 4.0, with an exception. See [here](https://www.kicad.org/libraries/license/) for more info.