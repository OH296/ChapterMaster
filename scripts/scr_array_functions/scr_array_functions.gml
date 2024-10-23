

function array_iter_length(choice_array, offset, length){
	if (length == 0){
		if (offset==0){
			length = array_length(choice_array);
		}
		else if (offset){
			length = array_length(choice_array) - offset;
		} else {
			length = offset*-1;
		}
	}
	return length;
}
function array_sum(choice_array,start_value=0, offset=0,length=0){
	function arraysum(_prev, _curr, _index) {
	    return _prev + _curr;
	}

	length = array_iter_length(choice_array,offset,length);

	return array_reduce(choice_array,arraysum,start_value,offset,length)
}

function array_set_value(choice_array, value){
	for (i=0;i<array_length(choice_array);i++){
		choice_array[@ i] = value;
	}
}

function array_replace_value(choice_array, value, r_value){
	for (i=0;i<array_length(choice_array);i++){
		if (choice_array[i] == value ){
			choice_array[@ i] = r_value;
		}
	}
}

function array_random_element(choice_array){
	return choice_array[irandom(array_length(choice_array) - 1)];
}

function array_random_index(choice_array){
	return irandom(array_length(choice_array) - 1);
}

function array_combine_strings(arr) {
    var uniqueItems = [];
    var itemCounts = [];

    for (var i = 0; i < array_length(arr); i++) {
        var item = arr[i];
        if (!array_contains(uniqueItems, item)) {
            array_push(uniqueItems, item);
            array_push(itemCounts, 1);
        } else {
            var index = array_get_index(uniqueItems, item);
            itemCounts[index]++;
        }
    }

    var result = "";
	var _array_length = array_length(uniqueItems);
    for (var j = 0; j < _array_length; j++) {
        var item = uniqueItems[j];
        if (itemCounts[j] > 1) {
            item += "s";
        }

		if (_array_length > 1) {
			if (j == _array_length - 1) {
				result += " and " + item;
			} else if (j == _array_length - 2){
				result += item;
			} else {
				result += item + ", ";
			}
		} else {
			result = item;
		}
    }

    return result;
}
