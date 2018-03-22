# List of BDAs

There are 3 BDAs that need to be run, one for each of *colorSize*, *typicality*, and *nominal choice*.

## Color / size choice

**Paper:** Section 3.2

One can do this in two different ways, one which is fast, and one which is slow. 

1. The fast way (reduced) is to represent each context as consisting of sets of objects with the following features: size (target feature), othersize, color (target feature), and othercolor. Utterances consist of the one- and two-word combinations of these features. This means there is no difference between the pin items and the wedding cake items, for instance. This is fine to do if we assume only 2 semantic values (one for size and one for color) and only 2 costs (one for size and one for color), and results in a total of 18 unique conditions.

	- **Conditions file:** bdaInput/unique_conditions_colorSize_reduced.json
	- **Data file:** bdaInput/data_bda_colorsize_reduced.csv -- still needs to be converted to .json -- the current contents of bda_data_colorSize_reduced.json are incorrect and appear to be based on the typicality dataset
The fast way is what I did for the paper because in that section we're not interested in differences between items.	

2. The slow way is to represent each context as consisting of objects that vary in color and type. Ie, the big/small pink/white wedding cake vs the big/small blue/red pin. This results in 1085 unique conditions so is much larger and takes much longer to run through than the reduced version in 1., but it can in principle incorporate differences in costs between colors, for instance. I haven't done this because it hasn't been necessary.

	- **Conditions file:** bdaInput/unique_conditions_colorSize.json
	- **Data file:** bdaInput/bda_data_colorSize.json

## Typicality

**Paper:** Section 4.3?

**Conditions file:** bdaInput/unique_conditions_typicality.json	

**Data file:**	bdaInput/bda_data_typicality.json


## Nominal choice

**Paper:** Section 5.3?

**Conditions file:** ??? ask Caroline

**Data file:**	??? ask Caroline