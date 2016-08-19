angular.module('travel').directive('onlydigits', function() {
    return {
        require: 'ngModel',
        link: function(scope, element, attr, ngModelCtrl) {
            var fromUser;
            fromUser = function(text) {
                var transformedInput;
                transformedInput = text.replace(/[^0-9]/g, '');
                if (transformedInput !== text) {
                    ngModelCtrl.$setViewValue(transformedInput);
                    ngModelCtrl.$render();
                }
                return transformedInput;
            };
            return ngModelCtrl.$parsers.push(fromUser);
        }
    };
});

// ---
// generated by coffee-script 1.9.2