// Contents of the file to be obfuscated.
var input = null;

// List of the names of the column headers 
// Assumes the first row of the file has named headers)
var fields = null;

// HTML file object
var file = null;

// Records that contains personally
// identifying information. These go into the "map" file.
var piiData = [];

// Records that contain data -- information that is not 
// anonymized. These go into the "data" file.
var anonymousData = [];

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
            input = results;
            fields = input.meta.fields;
			
			//Create the check boxes for the column headers. 
            populateHeaderList('checkbox', '50px')
        }
    });
}

// Overly generic function to create a list of buttons with the names
// of the column headers. Originally, you could set the primary key 
// independent of the columns to be removed from the data set. 
function populateHeaderList(type, leftMarg, callback) {

	// Grab the HTML element to use as a parent for the buttons
    var div = document.getElementById('header-list');
	
	//Indent the list of buttons
    div.style.marginLeft = leftMarg;

    //'Clear' the div element. Buttons do not appear if this is not executed.
    div.innerHTML = '';

	// For each fields, create a button (radio or checkbox), a label with the 
	// name for the column header, and break to put each button on its own line.
    fields.forEach(function (each) {
        // create the necessary elements
        var label = document.createElement("label");
        var description = document.createTextNode(each);
        var control = document.createElement("input");
        control.type = type;    
        control.name = 'headers';      // give it a name we can check
        control.setAttribute("header", each);
		
		// Function accepts an optional call back that is triggered when 
		// user checks or clicks a button.
        if (callback) {
            control.onclick = function () {
                callback(this);
            };
        }

		//Make the button and its description text children of the label.
        label.appendChild(control);   // add the box to the element
        label.appendChild(description);// add the description to the element

        //Add the label element to the div and then a break.
        div.appendChild(label);
        div.appendChild(document.createElement("br"));
    });
}

// Return a list of strings that represent the column headers the user
// selected.
function getPiiHeaders() {
    return _.chain(document.getElementsByName('headers'))
        .select(function (element) { return element.checked})
        .map(function (element) {return element.getAttribute('header')})
        .value();
}

// Populate the global data for the PII information and
// the anonymized information.
function createAnonData() {
    var pii = getPiiHeaders();
    _.each(input.data, function (row) {
        piiRow = _.pick(row, pii);
        anonRow = _.omit(row, pii);
        piiRow.ANONYMOUS = anonRow.ANONYMOUS = getUUID();
        piiData.push(piiRow);
        anonymousData.push(anonRow);
    });
}
// Create the PII and anonymous data sets, then save them as files.
function anonymize() {
    createAnonData();
    var type = {type: "text/plain;charset=utf-8"};
    saveAs(new Blob([Papa.unparse(piiData)], type), "anonymous_map.csv");
    saveAs(new Blob([Papa.unparse(anonymousData)], type), "anonymous_data.csv");
}

//Create a unique ID that has no relation to any of the original data.
function getUUID() {
    //Credit for this goes to http://stackoverflow.com/a/2117523/290962
    return 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}



