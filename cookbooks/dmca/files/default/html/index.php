<?php
session_start();
require_once 'HTML/QuickForm.php';
require_once 'HTML/QuickForm/DHTMLRulesTableless.php';
require_once 'HTML/QuickForm/Renderer/Tableless.php';

function process_data ($values) {
        echo '<h1>Thank you</h1>';
        echo 'Your report has been submitted';
        $email_body = 'OpenStreetMap - Claim of Copyright Infringement form:'."\n\n";
        $email_body .= 'Automated Email - Form Posted.'."\n\n";
        $email_body .= print_r($values, true);
        $reply_address = $values['name_first'].' '.$values['name_last'].' <'.$values['email'].'>';
        $email_body .= 'Formatted address: '.$reply_address."\n\n";
        $email_header = 'From: OSMF Copyright Form <dmca@osmfoundation.org>' . "\r\n" . 'Content-Type: text/plain; charset="utf-8"';
        mail('dmca@osmfoundation.org','OSM Claim of Copyright Infringement', $email_body, $email_header, '-fdmca@osmfoundation.org');
}
?>
<!DOCTYPE html>
<html>
<head>
<title>OpenStreetMap Legal - Claim of Copyright Infringement</title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
 <link rel="stylesheet" type="text/css" href="/style.css" />
</head>
<body>
<div class="regForm">
<?php
// Instantiate the HTML_QuickForm object
$form = new HTML_QuickForm_DHTMLRulesTableless('osm_legal_claim_of_copyright');
$renderer = new HTML_QuickForm_Renderer_Tableless();

$form->addElement('header', null, 'OpenStreetMap: Claim of Copyright Infringement');

$form->addElement('static', null, '<p>To file a copyright infringement notification with us, you will need to send a written communication that includes the following (please consult your legal counsel or see Section 512(c)(3) of the Digital Millennium Copyright Act to confirm these requirements):</p>
<ul><li> A physical or electronic signature of a person authorized to act on behalf of the owner of an exclusive right that is allegedly infringed.
<li>Identification of the copyrighted work claimed to have been infringed or, if multiple copyrighted works at a single online site are covered by a single notification, a representative list of such works at that site.
<li>Identification of the material that is claimed to be infringing or to be the subject of infringing activity and that is to be removed or access to which is to be disabled, and information reasonably sufficient to permit the service provider to locate the material. Providing URLs in the body of an email is the best way to help us locate content quickly.
<li>Information reasonably sufficient to permit the service provider to contact the complaining party, such as an address, telephone number, and, if available, an electronic mail address at which the complaining party may be contacted.
<li>A statement that the complaining party has a good faith belief that use of the material in the manner complained of is not authorized by the copyright owner, its agent, or the law.
<li>A statement that the information in the notification is accurate and, under penalty of perjury, that the complaining party is authorized to act on behalf of the owner of an exclusive right that is allegedly infringed.
</ul><p>To expedite our ability to process your request, such written notice should be sent to our designated agent via our online copyright complaint form below.</p>
<p>This form is only for cases where you believe that material on OpenStreetMap\'s websites or in its geodata database infringes your copyright or that of your clients. For example, you claim someone has copied material from a map belonging to you.</p>
<p>If you have come here for reporting map inaccuracies, privacy issues or another reason, <a href="https://wiki.osmfoundation.org/wiki/Licence_and_Legal_FAQ/Takedown_procedure/When_To_Use_The_Form">Read here</a>.</p>');

$form->addElement('text', 'url',                'URL of Allegedly Infringing Material', array('size' => 50, 'maxlength' => 255));
$form->addRule('url', 'Please enter URL of Allegedly Infringing Material', 'required', null, 'client');

$form->addElement('textarea', 'work',           'Describe the work allegedly infringed. For example, which map has been copied and what specifically has been copied.',  array('rows' => 20, 'cols' => 70));
$form->addRule('work', 'Please describe the work allegedly infringed', 'required', null, 'client');

$form->addElement('text', 'territory',          'Territories where infringement occurred', array('size' => 50, 'maxlength' => 255));
$form->addRule('territory', 'Please enter the territories where infringement occurred', 'required', null, 'client');

$form->addElement('text', 'name_first',         'First Name', array('size' => 50, 'maxlength' => 255));
$form->addRule('name_first', 'Please enter your First Name', 'required', null, 'client');

$form->addElement('text', 'name_last',          'Last Name', array('size' => 50, 'maxlength' => 255));
$form->addRule('name_last', 'Please enter your Last Name', 'required', null, 'client');


$form->addElement('text', 'company',            'Company Name', array('size' => 50, 'maxlength' => 255));
$form->addElement('text', 'company_tile',       'Title/Position');

$form->addElement('text', 'address',            'Street Address');
$form->addRule('address', 'Please enter Street Address', 'required', null, 'client');

$form->addElement('text', 'city',               'City', array('size' => 50, 'maxlength' => 255));
$form->addRule('city', 'Please enter City', 'required', null, 'client');

$form->addElement('text', 'state',              'State/Province', array('size' => 50, 'maxlength' => 255));
$form->addElement('text', 'postal_code',        'Zip/Postal Code', array('size' => 50, 'maxlength' => 255));

$form->addElement('text', 'country',            'Country', array('size' => 50, 'maxlength' => 255));
$form->addRule('country', 'Please enter Country', 'required', null, 'client');

$form->addElement('text', 'phone_number',       'Phone Number', array('size' => 50, 'maxlength' => 255));
$form->addRule('phone_number', 'Please enter Phone Number', 'required', null, 'client');

$form->addElement('text', 'mobile_number',      'Mobile Number', array('size' => 50, 'maxlength' => 255));

$form->addElement('text', 'email',              'Email Address', array('size' => 50, 'maxlength' => 255));
$form->addRule('email', 'Please enter Email Address', 'required', null, 'client');
$form->addRule('email', 'Please enter a valid Email Address', 'email', null, 'client');

$form->addElement('text', 'fax',                'Fax', array('size' => 50, 'maxlength' => 255));

$complaint_options = array();
$complaint_options[] = &HTML_QuickForm::createElement('checkbox', '1_of_4_owner_or_authorised', null, 'I am the owner, or an agent authorized to act on behalf of the owner, of an exclusive right that is allegedly infringed.');
$complaint_options[] = &HTML_QuickForm::createElement('checkbox', '2_of_4_good_faith', null, 'I have a good faith belief that the use of the material in the manner complained of is not authorized by the copyright owner, its agent, or the law; and');
$complaint_options[] = &HTML_QuickForm::createElement('checkbox', '3_of_4_accurate', null, 'This notification is accurate.');
$complaint_options[] = &HTML_QuickForm::createElement('checkbox', '4_of_4_not_misrepresent', null, 'I acknowledge that under Section 512(f) any person who knowingly materially misrepresents that material or activity is infringing may be subject to liability for damages.');

$form->addGroup($complaint_options, 'complaint_confirm', 'By checking the following boxes, I state UNDER PENALTY OF PERJURY that (choose all of the options)', '<br />');

$form->addElement('text', 'signature', 'Typing your full name in this box will act as your digital signature.', array('size' => 25, 'maxlength' => 255));
$form->addRule('signature', 'Field is required', 'required', null, 'client');

$form->addElement('submit', null, 'Send');

$form->removeAttribute('name');
$form->getValidationScript();

if ($form->validate()) {
    // Do some stuff
      $form->freeze();
      $form->process('process_data', false);

} else {
        // Output the form
        $form->accept($renderer);
        echo $renderer->toHtml();
}
?>
</div>
</body>
</html>
