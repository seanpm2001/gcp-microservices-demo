// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Checks if specified value has a valid units/nanos signs and ranges.
#
# + money - object to be validated
# + return - Validity
isolated function isValid(Money money) returns boolean {
    return signMatches(money) && validNanos(money.nanos);
}

# Checks if the sign matches.
#
# + money - object to be validated
# + return - validity status
isolated function signMatches(Money money) returns boolean {
    return money.nanos == 0 || money.units == 0 || (money.nanos < 0) == (money.units < 0);
}

# Checks if nanos are valid.
#
# + nanos - nano input
# + return - validity status
isolated function validNanos(int nanos) returns boolean {
    return -999999999 <= nanos && nanos <= +999999999;
}

# Checks if the money is zero.
#
# + money - object to be validated
# + return - zero status
isolated function isZero(Money money) returns boolean {
    return money.units == 0 && money.nanos == 0;
}

# Returns true if the specified money value is valid and is positive.
#
# + money - object to the validated
# + return - positive status
isolated function isPositive(Money money) returns boolean {
    return isValid(money) && money.units > 0 || (money.units == 0 && money.nanos > 0);
}

# Returns true if the specified money value is valid and is negative.
#
# + money - object to the validated
# + return - negative status
isolated function isNegative(Money money) returns boolean {
    return isValid(money) && money.units < 0 || (money.units == 0 && money.nanos < 0);
}

# Returns true if values l and r have a currency code and they are the same values.
#
# + l - first money object
# + r - second money object
# + return - currency type equal status
isolated function areSameCurrency(Money l, Money r) returns boolean {
    return l.currency_code == r.currency_code && l.currency_code != "";
}

# Returns true if values l and r are the equal, including the currency.
#
# + l - first money object
# + r - second money object
# + return - currency equal status
isolated function areEquals(Money l, Money r) returns boolean {
    return l.currency_code == r.currency_code && l.units == r.units && l.nanos == r.nanos;
}

# Negate returns the same amount with the sign negated.
#
# + money - object to be negated
# + return - negated money object
isolated function negate(Money money) returns Money {
    return {
        units: -money.units,
        nanos: -money.nanos,
        currency_code: money.currency_code
    };
}

# Sum adds two values.
#
# + l - first money object
# + r - second money object
# + return - sum money object
isolated function sum(Money l, Money r) returns Money {
    int nanosMod = 1000000000;

    int units = l.units + r.units;
    int nanos = l.nanos + r.nanos;

    if (units == 0 && nanos == 0) || (units > 0 && nanos >= 0) || (units < 0 && nanos <= 0) {
        // same sign <units, nanos>
        units += nanos / nanosMod;
        nanos = nanos % nanosMod;
    } else {
        // different sign. nanos guaranteed to not to go over the limit
        if units > 0 {
            units = units - 1;
            nanos += nanosMod;
        } else {
            units = units + 1;
            nanos -= nanosMod;
        }
    }

    return {
        units: units,
        nanos: nanos,
        currency_code: l.currency_code
    };
}

# Slow multiplication operation done through adding the value to itself n-1 times.
#
# + money - money object to be multiplied
# + factor - multiply factor
# + return - multiplied money object
isolated function multiplySlow(Money money, int factor) returns Money {
    int t = factor;
    Money out = money;
    while t > 1 {
        out = sum(out, money);
        t = t - 1;
    }
    return out;
}
