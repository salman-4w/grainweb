// TODO: change min length to 6

// Password validation
Ext.form.VTypes['passwordLength'] = /^.{3,40}$/;
Ext.form.VTypes['password'] = function(value) {
	if( !Ext.form.VTypes['passwordLength'].test(value) ) {
		Ext.form.VTypes['passwordText'] = 'Password length must be 3 to 40 characters long';
		return false;
	}
	return true;
};

// Password confirmation validation
Ext.form.VTypes['passwordConfirmation'] = function(value, field) {
	if( Ext.get(field.passwordField).getValue() != value ) {
		Ext.form.VTypes['passwordConfirmationText'] = "Password confirmation doesn't match password";
		return false;
	}
	return true;
};

// Location validation
Ext.form.VTypes['locationZip'] = /^\d+$/;
Ext.form.VTypes['locationCityAndState'] = /^\w+\s?\w+,\s?\w\w$/;
Ext.form.VTypes['location'] = function(value) {
	if( !Ext.form.VTypes['locationZip'].test(value) && !Ext.form.VTypes['locationCityAndState'].test(value) ) {
		Ext.form.VTypes['locationText'] = 'Location should be a ZIP code or string in "City, ST" format';
		return false;
	}
	return true;
};

// Float validation
Ext.form.VTypes['float'] = function(value) {
	if( isNaN(parseFloat(value)) ) {
		Ext.form.VTypes['floatText'] = 'Incorrect value';
		return false;
	}
	return true;
};
