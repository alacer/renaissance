// Contents of the file to be obfuscated.
var papaParseObject = null;

// List of the names of the column headers 
// Assumes the first row of the file has named headers)
var fields = null;

//List of actions to take on each column in the data
//var actions = null;

// HTML file object
var file = null;

//Keep track of fake values substituted for real values.
var replacementDictionary = {};


// This function accepts a list of files and loads the first 
// one into memory as a Papa parse object.
function loadFile(files) {

    // If no file is selected, alert the user.
    // The first check is to see if the user cancelled out of the
    // selection dialog without selecting a file. However, it is
    // OK to do that if a file was selected earlier and that is what
    // the second clause checks.
    if (files.length < 1 && !file) {
        alert("Please choose at least one file to parse.");
        return
    }

    //Set a globablly acessible variable.
    file = files[0];

    //Attempt to convert the selected file into a JSON object.
    Papa.parse(file, {
        header: true,
        error: function (err, file) {
            console.log("ERROR:", err, file);
            alert('Error logged to console.')
        },
        complete: function (results) {
            // Set the global variables input and fields.
            papaParseObject = results;
            fields = papaParseObject.meta.fields;

            //Create the instructions for what to do with the checkboxes
            $('#anchor-1').append('<h4 style="padding-top:25px">Choose the actions and then scroll to bottom.</h4>');

            //Create the check boxes for the column headers.
            createTableOfHeaders();

            //Reveal the anonymize button
            $('#anonymize-button').show();
        }
    });
}

function createTableOfHeaders() {

    //Create table element
    var table = document.createElement('table');
    table.setAttribute('class', 'table table-bordered');

    //Create table header
    var header = table.createTHead();

    // Create an empty <tr> element and add it to the first position of <thead>:
    var row = header.insertRow(0);

    // Insert a new cells (<td>)
    var cell0 = row.insertCell(0);
    var cell1 = row.insertCell(1);

    // Add some  text
    cell0.innerHTML = "Action";
    cell1.innerHTML = "Column Header";

    fields.forEach(function (each) {

        //Action column
        var tdAction = document.createElement('td');
        tdAction.className = 'table-bordered';

        //Action drop-down list
        var option1 = document.createElement("option");
        var option2 = document.createElement("option");
        var option3 = document.createElement("option");
        option1.text = "Retain as-is";
        option2.text = "Obfuscate";
        option3.text = "Remove";
        var ddList = document.createElement('SELECT');
        ddList.name = "actions";
        ddList.add(option1);
        ddList.add(option2);
        ddList.add(option3);

        //Attach drop-down list to cell
        tdAction.appendChild(ddList);

        //Header column
        var tdFieldName = document.createElement('td');
        tdFieldName.className = 'table-bordered';
        tdFieldName.appendChild(document.createTextNode(each));

        //Attach cells to row
        var tr = document.createElement('tr');
        tr.appendChild(tdAction);
        tr.appendChild(tdFieldName);

        //Attach row to table
        table.appendChild(tr);
    });

    //Attach table to document
    document.getElementById('anchor-2').appendChild(table);
}


function getActions() {
    //Return an object whose keys are column headers and whose values are action strings.
    var obj = {};
    var controls = $("select");
    for (var i = 0; i < fields.length; ++i) {
        obj[fields[i]] = controls[i].value;
    }
    return obj;
}

// Populate the global data for the PII information and
// the anonymized information.
function createData(actions) {

    //Get the raw, unanonymized data
    var rawData = papaParseObject.data;

    //Create a place to hold the key data and scrubbed data
    var dataSets = {};
    dataSets.key = [];
    dataSets.scrubbed = [];

    //Iterate over every row of the raw data.
    var numRecords = rawData.length - 1;
    for (var i = 0; i < numRecords; ++i) {

        //For some reason Papa Parse always grabs an extra row.
        //This code skips the last row.
        if (i == numRecords - 1) {
            console.log('SKIPPING LAST ROW ', rawData[i+1])
            break;
        }

        //Get a handle on the row
        var rawRow = rawData[i];

        //Create hash to use as unique ID to link records in the key file
        //to records in the scrubbed file.
        var id = chance.hash();

        //Create and add a field to both the key file and scrubbed file to permit later merge.
        var scrubbedRow = {ANONYMOUS_ID: id};
        var keyRow = {ANONYMOUS_ID: id};
        dataSets.scrubbed.push(scrubbedRow);
        dataSets.key.push(keyRow);

        //Iterate through every field in the row.
        for (var columnHeader in rawRow) {

            //Pull out the requested action for the column
            var theAction = actions[columnHeader];

            //Pull out the actual value from the raw data
            var realValue = rawRow[columnHeader];

            //Obfuscate means to leave the column in the scrubbed data, but
            //replace the values with garbage. A real value will always be replaced
            //by the same fake value.
            if (theAction == 'Obfuscate') {
                //Copy the real value into the key file
                keyRow[columnHeader] = realValue;

                //Copy the fake value into the scrubbed file
                scrubbedRow[columnHeader] = getFakeValue(realValue);

                //Copy the fake value into the key file
                keyRow[columnHeader + 'Obfuscated'] = getFakeValue(realValue);                
            }

            //The column should not appear in the scrubbed data, but the column should
            //appear on the key data.
            //NOTE: This could be pulled out of this loop with some rework.
            if (theAction == 'Remove') {
                keyRow[columnHeader] = realValue;
            }

            if (theAction == 'Retain as-is') {
                scrubbedRow[columnHeader] = realValue;
            }
        } //End iterating over cells

    }//End iterating over rows

    return dataSets;

}//End function

function getFakeValue(realValue) {
    //Replace the real value with a surrogate.
    //Consult the replacement dictionary. If this value has been
    //seen before, use the same replacement. Otherwise, add it
    //to the replacement dictionary
    var fakeValue = replacementDictionary[realValue];
    if (!fakeValue) {
        fakeValue = chance.word({syllables: 4});
        replacementDictionary[realValue] = fakeValue;
    }
    return fakeValue;
}

function anonymize() {
    //Create the key and scrubbed data sets and save them as files
    var dataSets = createData(getActions());
    var type = {type: "text/plain;charset=utf-8"};
    saveAs(new Blob([Papa.unparse(dataSets.key)], type), "key_file.csv");
    saveAs(new Blob([Papa.unparse(dataSets.scrubbed)], type), "scrubbed_file.csv");
}


