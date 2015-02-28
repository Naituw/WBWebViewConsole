/*
 *  Copyright (c) 2014-present, Weibo, Corp.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 *  This file is written based on WebKit's CodeMirrorCompletionController.js
 *
 * Copyright (C) 2013 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

(function(string, cursor) {

	if (typeof String.prototype.startsWith != 'function') {
		String.prototype.startsWith = function(str) {
			return this.slice(0, str.length) == str;
		};
	}

	if (typeof String.prototype.contains != 'function') {
		String.prototype.contains = function(it) {
			return this.indexOf(it) != -1;
		};
	}

	if (typeof Array.prototype.keySet != 'function') {
		Array.prototype.keySet = function() {
        	var keys = {};
        	for (var i = 0; i < this.length; ++i)
        	    keys[this[i]] = true;
        	return keys;
    	}
	}

	function _scanStringForExpression(string, startOffset, direction, allowMiddleAndEmpty, includeStopCharacter, ignoreInitialUnmatchedOpenBracket, stopCharactersRegex) {

		// console.assert(direction === -1 || direction === 1);

		var stopCharactersRegex = stopCharactersRegex || /[\s=:;,!+\-*/%&|^~?<>.{}()[\]]/;

		function isStopCharacter(character) {
			return stopCharactersRegex.test(character);
		}

		function isOpenBracketCharacter(character) {
			return /[({[]/.test(character);
		}

		function isCloseBracketCharacter(character) {
			return /[)}\]]/.test(character);
		}

		function matchingBracketCharacter(character) {
			return {
				"{": "}",
				"(": ")",
				"[": "]",
				"}": "{",
				")": "(",
				"]": "["
			}[character];
		}

		var endOffset = Math.min(startOffset, string.length);

		var endOfLineOrWord = endOffset === string.length || isStopCharacter(string.charAt(endOffset));

		if (!endOfLineOrWord && !allowMiddleAndEmpty)
			return null;

		var bracketStack = [];
		var bracketOffsetStack = [];
		var lastCloseBracketOffset = NaN;

		var startOffset = endOffset;
		var firstOffset = endOffset + direction;
		for (var i = firstOffset; direction > 0 ? i < string.length : i >= 0; i += direction) {
			var character = string.charAt(i);

			// Ignore stop characters when we are inside brackets.
			if (isStopCharacter(character) && !bracketStack.length)
				break;

			if (isCloseBracketCharacter(character)) {
				bracketStack.push(character);
				bracketOffsetStack.push(i);
			} else if (isOpenBracketCharacter(character)) {
				if ((!ignoreInitialUnmatchedOpenBracket || i !== firstOffset) &&
					(!bracketStack.length || matchingBracketCharacter(character) !== bracketStack.lastValue))
					break;

				bracketOffsetStack.pop();
				bracketStack.pop();
			}

			startOffset = i + (direction > 0 ? 1 : 0);
		}

		if (bracketOffsetStack.length)
			startOffset = bracketOffsetStack.pop() + 1;

		if (includeStopCharacter && startOffset > 0 && startOffset < string.length)
			startOffset += direction;

		if (direction > 0) {
			var tempEndOffset = endOffset;
			endOffset = startOffset;
			startOffset = tempEndOffset;
		}

		return {
			string: string.substring(startOffset, endOffset),
			startOffset: startOffset,
			endOffset: endOffset
		};
	};

	function _generateJavaScriptCompletions(base, prefix, suffix)
    {
        // If there is a base expression then we should not attempt to match any keywords or variables.
        // Allow only open bracket characters at the end of the base, otherwise leave completions with
        // a base up to the delegate to figure out.
        if (base && !/[({[]$/.test(base))
            return [];

        var matchingWords = [];

        const allKeywords = ["break", "case", "catch", "const", "continue", "debugger", "default", "delete", "do", "else", "false", "finally", "for", "function", "if", "in",
            "Infinity", "instanceof", "NaN", "new", "null", "return", "switch", "this", "throw", "true", "try", "typeof", "undefined", "var", "void", "while", "with"];
        const valueKeywords = ["false", "Infinity", "NaN", "null", "this", "true", "undefined"];

        function matchKeywords(keywords)
        {
            matchingWords = matchingWords.concat(keywords.filter(function(word) {
                return word.startsWith(prefix);
            }));
        }

        switch (suffix.substring(0, 1)) {
        case "":
        case " ":
            matchKeywords(allKeywords);
            break;

        case ".":
        case "[":
            matchKeywords(["false", "Infinity", "NaN", "this", "true"]);
            break;

        case "(":
            matchKeywords(["catch", "else", "for", "function", "if", "return", "switch", "throw", "while", "with"]);
            break;

        case "{":
            matchKeywords(["do", "else", "finally", "return", "try"]);
            break;

        case ":":
            matchKeywords(["case", "default"]);
            break;

        case ";":
            matchKeywords(valueKeywords);
            matchKeywords(["break", "continue", "debugger", "return", "void"]);
            break;
        }

        return matchingWords;
    };


	function completionControllerCompletionsNeeded(defaultCompletions, base, prefix, suffix, forced) {
		// Don't allow non-forced empty prefix completions unless the base is that start of property access.
		if (!forced && !prefix && !/[.[]$/.test(base)) {
			return null;
		}

		// If the base ends with an open parentheses or open curly bracket then treat it like there is
		// no base so we get global object completions.
		if (/[({]$/.test(base))
			base = "";

		if (!base.length) {
			base = "window";
		}

		var lastBaseIndex = base.length - 1;
		var dotNotation = base[lastBaseIndex] === ".";
		var bracketNotation = base[lastBaseIndex] === "[";

		if (dotNotation || bracketNotation) {
			base = base.substring(0, lastBaseIndex);

			// Don't suggest anything for an empty base that is using dot notation.
			// Bracket notation with an empty base will be treated as an array.
			if (!base && dotNotation) {
				return defaultCompletions;
			}

			// Don't allow non-forced empty prefix completions if the user is entering a number, since it might be a float.
			// But allow number completions if the base already has a decimal, so "10.0." will suggest Number properties.
			if (!forced && !prefix && dotNotation && base.indexOf(".") === -1 && parseInt(base, 10) == base) {
				return null;
			}

			// An empty base with bracket notation is not property access, it is an array.
			// Clear the bracketNotation flag so completions are not quoted.
			if (!base && bracketNotation)
				bracketNotation = false;
		}

		function evaluated(result, wasThrown) {
			var type = typeof result;
			if (wasThrown || !type || type === "undefined" || (type === "object" && result == null)) {
				return defaultCompletions;
			}

			function getCompletions(primitiveType) {
				var object;
				if (primitiveType === "string")
					object = new String("");
				else if (primitiveType === "number")
					object = new Number(0);
				else if (primitiveType === "boolean")
					object = new Boolean(false);
				else
					object = this;

				var resultSet = {};
				for (var o = object; o; o = o.__proto__) {
					try {
						var names = Object.getOwnPropertyNames(o);
						for (var i = 0; i < names.length; ++i)
							resultSet[names[i]] = true;
					} catch (e) {
						// Ignore
					}
				}

				return resultSet;
			}

			if (type === "object" || type === "function")
				return getCompletions.apply(result, [type]);
			else if (type === "string" || type === "number" || type === "boolean")
				return getCompletions(type);

			return {};
			// else
			//     console.error("Unknown result type: " + result.type);
		}


		function receivedPropertyNames(propertyNames) {
			propertyNames = propertyNames || {};

			propertyNames = Object.keys(propertyNames);

			var implicitSuffix = "";
			if (bracketNotation) {
				var quoteUsed = prefix[0] === "'" ? "'" : "\"";
				if (suffix !== "]" && suffix !== quoteUsed)
					implicitSuffix = "]";
			}

			var completions = defaultCompletions;
			var knownCompletions = completions.keySet();

			for (var i = 0; i < propertyNames.length; ++i) {
				var property = propertyNames[i];

				if (dotNotation && !/^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(property))
					continue;

				if (bracketNotation) {
					if (parseInt(property) != property)
						property = quoteUsed + property.escapeCharacters(quoteUsed + "\\") + (suffix !== quoteUsed ? quoteUsed : "");
				}

				if (!property.startsWith(prefix) || property === prefix || property in knownCompletions)
					continue;

				completions.push(property);
				knownCompletions[property] = true;
              
               // if (completions.length > 100) {
               //     break; // get first 100 properties
               // }
			}

			function compare(a, b) {
				// Try to sort in numerical order first.
				var numericCompareResult = a - b;
				if (!isNaN(numericCompareResult))
					return numericCompareResult;

				// Not numbers, sort as strings.
                return (a < b ? -1 : (a > b ? 1 : 0));

                // implementation below by webkit is extremely slow, but handles non-english strings better
				// return a.localeCompare(b);
			}

			completions.sort(compare);

			return completions;
		}

		var propertyNames = {};

		try {
			(function() {
				var result = eval(base);
				propertyNames = evaluated(result, false);
			})();
		} catch (error) {
			propertyNames = evaluated(null, true);
		}

		return receivedPropertyNames(propertyNames);
	};

	try {
		var lineString = decodeURIComponent(escape(window.atob(string)));

		var force = false;

		var backwardScanResult = _scanStringForExpression(lineString, cursor, -1, force);

		if (!backwardScanResult) {
			return;
		}

		var forwardScanResult = _scanStringForExpression(lineString, cursor, 1, true, true);
		var suffix = forwardScanResult.string;

		var _startOffset = backwardScanResult.startOffset;
		var _endOffset = backwardScanResult.endOffset;
		var _prefix = backwardScanResult.string;
		var _completions = [];
		var _implicitSuffix = "";
		var _forced = force;

		var baseExpressionStopCharactersRegex = /[\s=:;,!+\-*/%&|^~?<>]/;
		if (baseExpressionStopCharactersRegex)
			var baseScanResult = _scanStringForExpression(lineString, _startOffset, -1, true, false, true, baseExpressionStopCharactersRegex);

		if (!force && !backwardScanResult.string && (!baseScanResult || !baseScanResult.string)) {
			return;
		}

		var defaultCompletions = [];

		defaultCompletions = _generateJavaScriptCompletions(baseScanResult ? baseScanResult.string : null, _prefix, suffix);

		// TODO: add javascript default completions

		_completions = completionControllerCompletionsNeeded(defaultCompletions, baseScanResult ? baseScanResult.string : null, _prefix, suffix, force);

		var result = {
			completions: _completions,
			token_start: _startOffset,
			token_end: _endOffset
		}

		if (_completions.length) {
			return JSON.stringify(result);
		} else {
			return;
		}
	} catch (error) {
		return;
	}
	return;
})