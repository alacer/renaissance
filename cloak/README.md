## Alacer Data Cloak 

### Possible Enhancements

- Obfuscate a column name in the scrubbed data file. (Hard: This information would have to saved in a third file)
- Display the values of the first row of the original data in the browser to help the user understand what information is stored in each column. This could be helpful 
- Reset the UI after a file has been anonymized.
- Allow user to change the names of the output files.
- Add an action to "fuzz" numerical data so that numerical values that appear in the scrubbed data are not exactly the same as in the original data. This can be used on attributes "height" and "weight", which are protected by HIPPA, to be used in for data analysis. The fuzzing can be done in such a way that the  distribution of the scrubbed values approximates the distribution of the original values.
- Add actions to generate random phone number, personal names, addresses, social security number, etc. 
- Ability to retain keys across multiple tables. For example, a social security number in an original file might be used as a foreign key into another original file. Currently, the same social security number would have different obfuscated values in each file. (Dev note: Use a hash function for this so we don't have to save values to disk)

### Features/Known Limitations

1. Obfuscated (fake) values are randomly generated, but are not guaranteed to be unique. If "John Smith" is obfuscated as "tuleroll", then there is (very small) chance that another value in the same column, e.g. "Sandy Sue" will also be obfuscated as "tuleroll". The chance of this happening increases with the number unique values in the original data set. At some point, the original data could be so big that set of obfuscated values could entirely exhausted.
2. The Chrome browser implements the function saveAs. This function is use to save the file locally. The entire contents of the file must be passed to the saveAs function and it is not possible to stream data to the output files. This limits the size of a data file than can be anonymized. At some point, the client machine will run out of memory and the application stop responding.
3. The application does not reset the UI after a file has been anonymized. This mean that the browser must be refreshed via F5 or by clicking the refresh button. To see the behavior, anonymize a file and then use "Browser" to select another file.
4. There is no check for binary data. Loading a binary file will display garbage.
5. Chrome's saveAs function does not allow the user to choose the directory where the file will be saved.
6. The original data file MUST have a header row.