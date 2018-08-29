<?php
/**
 * DHTML replacement for the standard JavaScript alert window for client-side
 * validation
 *
 * LICENSE:
 * 
 * Copyright (c) 2005-2007, Mark Wiesemann <wiesemann@php.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the 
 *      documentation and/or other materials provided with the distribution.
 *    * The names of the authors may not be used to endorse or promote products 
 *      derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @category   HTML
 * @package    HTML_QuickForm_DHTMLRulesTableless
 * @author     Alexey Borzov <borz_off@cs.msu.su>
 * @author     Adam Daniel <adaniel1@eesus.jnj.com>
 * @author     Bertrand Mansion <bmansion@mamasam.com>
 * @author     Justin Patrin <papercrane@gmail.com>
 * @author     Mark Wiesemann <wiesemann@php.net>
 * @license    http://www.opensource.org/licenses/bsd-license.php New BSD License
 * @version    CVS: $Id: PageDHTMLRulesTableless.php,v 1.3 2007/10/24 20:36:11 wiesemann Exp $
 * @link       http://pear.php.net/package/HTML_QuickForm_DHTMLRulesTableless
 */

require_once 'HTML/QuickForm/Page.php';

/**
 * This is a DHTML replacement for the standard JavaScript alert window for
 * client-side validation of forms built with HTML_QuickForm
 *
 * @category   HTML
 * @package    HTML_QuickForm_DHTMLRulesTableless
 * @author     Alexey Borzov <borz_off@cs.msu.su>
 * @author     Adam Daniel <adaniel1@eesus.jnj.com>
 * @author     Bertrand Mansion <bmansion@mamasam.com>
 * @author     Justin Patrin <papercrane@gmail.com>
 * @author     Mark Wiesemann <wiesemann@php.net>
 * @license    http://www.opensource.org/licenses/bsd-license.php New BSD License
 * @version    Release: 0.3.3
 * @link       http://pear.php.net/package/HTML_QuickForm_DHTMLRulesTableless
 */
class HTML_QuickForm_PageDHTMLRulesTableless extends HTML_QuickForm_Page
{
   /**
    * Class constructor
    * 
    * @access public
    */
    function HTML_QuickForm_PageDHTMLRulesTableless($formName, $method = 'post',
        $target = '', $attributes = null)
    {
        $this->HTML_QuickForm_Page($formName, $method, '', $target, $attributes);
    }

    // {{{ getValidationScript()

    /**
     * Returns the client side validation script
     *
     * The code here was copied from HTML_QuickForm and slightly modified to run rules per-element
     *
     * @access    public
     * @return    string    Javascript to perform validation, empty string if no 'client' rules were added
     */
    function getValidationScript()
    {
        if (empty($this->_rules) || empty($this->_attributes['onsubmit'])) {
            return '';
        }

        include_once('HTML/QuickForm/RuleRegistry.php');
        $registry =& HTML_QuickForm_RuleRegistry::singleton();
        $test = array();
        $js_escape = array(
            "\r"    => '\r',
            "\n"    => '\n',
            "\t"    => '\t',
            "'"     => "\\'",
            '"'     => '\"',
            '\\'    => '\\\\'
        );

        foreach ($this->_rules as $elementName => $rules) {
            foreach ($rules as $rule) {
                if ('client' == $rule['validation']) {
                    unset($element);

                    $dependent  = isset($rule['dependent']) && is_array($rule['dependent']);
                    $rule['message'] = strtr($rule['message'], $js_escape);

                    if (isset($rule['group'])) {
                        $group    =& $this->getElement($rule['group']);
                        // No JavaScript validation for frozen elements
                        if ($group->isFrozen()) {
                            continue 2;
                        }
                        $elements =& $group->getElements();
                        foreach (array_keys($elements) as $key) {
                            if ($elementName == $group->getElementName($key)) {
                                $element =& $elements[$key];
                                break;
                            }
                        }
                    } elseif ($dependent) {
                        $element   =  array();
                        $element[] =& $this->getElement($elementName);
                        foreach ($rule['dependent'] as $idx => $elName) {
                            $element[] =& $this->getElement($elName);
                        }
                    } else {
                        $element =& $this->getElement($elementName);
                    }
                    // No JavaScript validation for frozen elements
                    if (is_object($element) && $element->isFrozen()) {
                        continue 2;
                    } elseif (is_array($element)) {
                        foreach (array_keys($element) as $key) {
                            if ($element[$key]->isFrozen()) {
                                continue 3;
                            }
                        }
                    }

                    $test[$elementName][] = $registry->getValidationScript($element, $elementName, $rule);
                }
            }
        }
        $js = '
<script type="text/javascript"><!--//--><![CDATA[//><!--
qf_errorHandler = function(element, _qfMsg) {
  div = element.parentNode;
  var elementName = element.name.replace(/\[/, "_____");
  var elementName = elementName.replace(/\]/, "_____");
  if (_qfMsg != \'\') {
    span = document.createElement("span");
    span.className = "error";
    _qfMsg = _qfMsg.substring(4);
    span.appendChild(document.createTextNode(_qfMsg));
    br = document.createElement("br");

    var errorDiv = document.getElementById(elementName + \'_errorDiv\');
    if (!errorDiv) {
      errorDiv = document.createElement("div");
      errorDiv.id = elementName + \'_errorDiv\';
    } else {
      if (   div.firstChild.textContent == \'\'
          || _qfMsg == div.firstChild.textContent
         ) {
        return false;
      }
    }
    while (errorDiv.firstChild) {
      errorDiv.removeChild(errorDiv.firstChild);
    }

    errorDiv.insertBefore(br, errorDiv.firstChild);
    errorDiv.insertBefore(span, errorDiv.firstChild);

    errorDivInserted = false;
    for (var i = element.parentNode.childNodes.length - 1; i >= 0; i--) {
      j = i - 1;
      if (j >= 0 && element.parentNode.childNodes[j].nodeName == "DIV") {
        element.parentNode.insertBefore(errorDiv, element.parentNode.childNodes[i]);
        errorDivInserted = true;
        break;
      }
    }
    if (!errorDivInserted) {
      element.parentNode.insertBefore(errorDiv, element.parentNode.firstChild);
    }

    if (div.className.substr(div.className.length - 6, 6) != " error"
        && div.className != "error") {
      div.className += " error";
    }

    return false;
  } else {
    var errorDiv = document.getElementById(elementName + \'_errorDiv\');
    if (errorDiv) {
      errorDiv.parentNode.removeChild(errorDiv);
    }
    
    // do not remove the error style from the div tag if there is still an error
    // message
    if (div.firstChild.innerHTML != "") {
      return true;
    }

    if (div.className.substr(div.className.length - 6, 6) == " error") {
      div.className = div.className.substr(0, div.className.length - 6);
    } else if (div.className == "error") {
      div.className = "";
    }

    return true;
  }
}';
        $validateJS = '';
        foreach ($test as $elementName => $jsArr) {
            // remove group element part of the element name to avoid JS errors
            $singleElementName = $elementName;
            $shortNameForJS = str_replace(array('[', ']'), '__', $elementName);
            $bracketPos = strpos($elementName, '[');
            if ($bracketPos !== false) {
                $singleElementName = substr($elementName, 0, $bracketPos);
                $groupElementName = substr($elementName, $bracketPos + 1, -1);
            }
            if ($bracketPos === false || !$this->elementExists($singleElementName)) {
                $groupElementName = $elementName;
                $singleElementName = $elementName;
            }
            $id = str_replace('-', '_', $this->_attributes['id']);
            $js .= '
validate_' . $id . '_' . $shortNameForJS . ' = function(element) {
  var value = \'\';
  var errFlag = new Array();
  var _qfGroups = {};
  var _qfMsg = \'\';
  var frm = element.parentNode;
  while (frm && frm.nodeName != "FORM") {
    frm = frm.parentNode;
  }
' . join("\n", $jsArr) . '
  return qf_errorHandler(element, _qfMsg);
}
';
            unset($element);
            $element =& $this->getElement($singleElementName);
            $elementNameForJS = 'frm.elements[\'' . $elementName . '\']';
            if ($element->getType() === 'group' && $singleElementName === $elementName) {
                $elementNameForJS = 'document.getElementById(\'' . $element->_elements[0]->getAttribute('id') . '\')';
            }
            $validateJS .= '
  ret = validate_' . $id . '_' . $shortNameForJS . '('. $elementNameForJS . ') && ret;';
            if ($element->getType() !== 'group') {  // not a group
                $valFunc = 'validate_' . $id . '_' . $shortNameForJS . '(this)';
                $onBlur = $element->getAttribute('onBlur');
                $onChange = $element->getAttribute('onChange');
                $element->updateAttributes(array('onBlur' => $onBlur . $valFunc,
                                                 'onChange' => $onChange . $valFunc));
            } else {  // group
                $elements =& $element->getElements();
                for ($i = 0; $i < count($elements); $i++) {
                    // $groupElementName is a substring of attribute name of the element
                    if (strpos($elements[$i]->getAttribute('name'), $groupElementName) === 0) {
                        $valFunc = 'validate_' . $id . '_' . $shortNameForJS . '(this)';
                        $onBlur = $elements[$i]->getAttribute('onBlur');
                        $onChange = $elements[$i]->getAttribute('onChange');
                        $elements[$i]->updateAttributes(array('onBlur'   => $onBlur . $valFunc,
                                                              'onChange' => $onChange . $valFunc));
                    }
                }
            }
        }
        $js .= '
validate_' . $id . ' = function (frm) {
  var ret = true;
' . $validateJS . ';
  return ret;
}
//--><!]]></script>';
        return $js;
    } // end func getValidationScript

    // }}}

    function display() {
        $this->getValidationScript();
        return parent::display();
    }
}

?>