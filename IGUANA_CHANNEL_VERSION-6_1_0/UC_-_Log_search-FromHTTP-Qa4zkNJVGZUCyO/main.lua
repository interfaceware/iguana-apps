require 'hl7util'
require 'node'

-- YOU MUST SET THESE PARAMETERS TO MATCH YOUR INSTALLATION
-- NOTE:  THE TRAILING SLASH IS REQUIRED
-- local URL = 'http://conference.interfaceware.com:6543/'
local URL = 'http://localhost:6543/'
local auth={username='admin', password='password'}


-- THE MAIN FUNCTION
function main(Data)
   
   -- TELL IGUANA NOT TO STOP THIS CHANNEL IF THERE IS AN ERROR
   iguana.stopOnError(false)
   
   -- GET AND PARSE THE REQEST INFORMATION
   local R = net.http.parseRequest{data=Data}
   trace(R)
   
   -- IF THIS WAS A SUBMISSION OF THE FORM, THEN:
   if R.location == '/log/go/' then
      
      -- GET THE FORM VALUES
      Search = R.params.Search
      Seg = R.params.Seg
      Field = R.params.FieldNum
      Channel = R.params.Channel
      Time = R.params.Time
      
      -- STATIC VALUES DEPICTING TIME FRAMES
      local Wayback = {
         day = 86400,
         week = 604800,
         month = 2419200,
         year = 31536000
      }
      local SearchTime = os.ts.date("%Y/%m/%d %X", os.ts.time() - Wayback[Time])
      
      -- QUERY THE LOGS WITH ALL THE PARAMETERS
      local LogList = net.http.post{
         url=URL ..'api_query',
         auth=auth, 
         parameters={type='messages', after=SearchTime, filter=Search, source=Channel},
         live=true
      }
      
      local Logs = xml.parse{data=LogList}
      local Found = ''
      local FoundCount = 0
      
      -- LOOP THROUGH MESSAGES SEARCHING FOR STRING
      for x=1, Logs.export:childCount("message") do 
         local RawMsg = Logs.export:child("message", x).data:nodeValue()
         local Msg = hl7.parse{vmd='HL7_2.5.1.vmd', data=RawMsg}
         local Segment = hl7util.findSegment(Msg, FindSegment)
         if Segment ~= nil then
         
            SegString = Segment[tonumber(Field)]:S()
            
            -- IF A MATCH IS FOUND, BUILD THE RESULT STRING
            if SegString:match(Search) ~= nil then 
               Found = Found .. '<a href="' .. URL .. 'log_browse?refid=' .. 
               Logs.export:child("message", x).message_id .. '">' .. 
               RawMsg .. 
               '</a>\n\n\n'
               FoundCount = FoundCount +1
            end
         end
         
      end
      Found = '<pre><b>Matches: ' .. FoundCount ..'</b>\n\n' .. Found .. '</pre>'
      net.http.respond{body=Found}
   else
      net.http.respond{body=HTML}
   end
end

-- HELPER FUNCTION TO FIND SEGMENT

function FindSegment(ThisSegment)
   if ThisSegment:nodeName() == Seg then
      return true
   end
end

-- THE HTML FOR THE FORM
HTML = [[<!DOCTYPE html>
<html  lang="">
<head>
<title>Log Search</title>
<meta charset="utf-8" />
<!--[if IE]>
<link rel="stylesheet" type="text/css" media="all" href="https://www.formstack.com/forms/css/3/ie.css?20140508" />
<![endif]-->
<!--[if IE 7]><link rel="stylesheet" type="text/css" media="all" href="https://www.formstack.com/forms/css/3/ie7.css" /><![endif]-->
<!--[if IE 6]><link rel="stylesheet" type="text/css" media="all" href="https://www.formstack.com/forms/css/3/ie6fixes.css" /><![endif]-->
<link rel="stylesheet" type="text/css" href="https://www.formstack.com/forms/css/3/reset.css?20140508" />
<link rel="stylesheet" type="text/css" href="https://www.formstack.com/forms/css/3/default.css?20140925" />
<link rel="stylesheet" type="text/css" href="https://www.formstack.com/forms/css/3/steel.css" />
<style type="text/css">

.fsBody .fsForm {
    -webkit-box-shadow:0 5px 15px 3px #666666;
       -moz-box-shadow:0 5px 15px 3px #666666;
            box-shadow:0 5px 15px 3px #666666;
}
    
.fsFieldFocused {
	background-color: #e7f4f9;
}
    
.fsBody .fsSectionHeader {
    background: none repeat scroll 0 0 #73bf44;
    color: #FFFFFF;
    padding-left: 55px;
}

.fsBody .fsForm .fsSectionHeading {
    font-size: 34px;
    font-family: 'Open Sans';
    font-weight: 200;
    line-height: 44px;
}

.fsBody .fsFieldRow {
    border-top: 1px solid #EEEEEE;
    padding: 6px 0px 6px 40px;
    font-family: 'Open Sans';
    font-size: 14px;
    color: #444444;
}
    
.fsFieldRow input[type="checkbox"], .fsFieldRow input[type="radio"] {
    margin: 3px 20px 0 0;
}
    
input {
    border: 1px solid #888888;
}

.fsRequiredMarker {
    color: #ba0000;
    float: none;
    font-family: Verdana;
    font-size: 12px;
    font-weight: 700;
    padding-left: 2px;
}
    
.fsSubmit input.fsSubmitButton {
    background: none repeat scroll 0 0 #73bf44;
    border: 1px solid #82b964;
    color: #ffffff;
    padding: 15px 30px;
    -webkit-border-radius:5px;
       -moz-border-radius:5px;
            border-radius:5px;
    font-family: 'Open Sans';
}
    
</style>
</head>
<body class="fsBody" id="fsLocal">
<form method="post" novalidate action="/log/go/" class="fsForm fsSingleColumn fsMaxCol1" id="fsForm1841988">
<div role="alert" id="requiredFieldsError" style="display:none;">Please fill in a valid value for all required fields</div>
<div role="alert" id="invalidFormatError" style="display:none;">Please ensure all values are in a proper format.</div>
<div role="alert" id="resumeConfirm" style="display:none;">Are you sure you want to leave this form and resume later?</div>
<div role="alert" id="fileTypeAlert" style="display:none;">You must upload one of the following file types for the selected field:</div>
<div role="alert" id="embedError" style="display:none;">There was an error displaying the form. Please copy and paste the embed code again.</div>
<div role="alert" id="applyDiscountButton" style="display:none;">Apply Discount</div>
<div role="alert" id="dcmYouSaved" style="display:none;">You saved</div>
<div role="alert" id="dcmWithCode" style="display:none;">with code</div>
<div role="alert" id="submitButtonText" style="display:none;">Submit Form</div>
<div role="alert" id="submittingText" style="display:none;">Submitting</div>
<div class="fsPage" id="fsPage1841988-1">
<div class="fsSection fs1Col" id="fsSection27920863">
<div class="fsSectionHeader">
<h2 class="fsSectionHeading">Log Search</h2>
</div>
<div id="fsRow1841988-2" class="fsRow fsFieldRow fsLastRow">
<div class="fsRowBody fsCell fsFieldCell  fsFirst fsLast fsLabelVertical  fsSpan100 " id="fsCell27921194" aria-describedby="fsSupporting27921194" lang="en">
<label id="label27921194" class="fsLabel" for="Time">Timeframe                                            </label>
<select id="Time" name="Time" size="1"  class="fsField" aria-required="false" >
<option value="day" selected="selected">day</option>
<option value="week" >week</option>
<option value="month" >month</option>
<option value="year" >year</option>
</select>
<div id="fsSupporting27921194" class="fsSupporting">Previous day, week month or year...</div>
</div>
</div>
<div id="fsRow1841988-3" class="fsRow fsFieldRow fsLastRow">
<div class="fsRowBody fsCell fsFieldCell  fsFirst fsLast fsLabelVertical  fsSpan100 " id="fsCell27920801" lang="en">
<label id="label27920801" class="fsLabel fsRequiredLabel" for="Search">Search For:<span class="fsRequiredMarker">*</span>                                            </label>
<input type="text" id="Search" name="Search" size="50" required placeholder="ADT^A08" title="ADT^A08" value="" class="fsField fsRequired" aria-required="true" />
</div>
</div>
<div id="fsRow1841988-4" class="fsRow fsFieldRow fsLastRow">
<div class="fsRowBody fsCell fsFieldCell  fsFirst fsLast fsLabelVertical  fsSpan100 " id="fsCell27920808" lang="en">
<label id="label27920808" class="fsLabel fsRequiredLabel" for="Seg">Segment<span class="fsRequiredMarker">*</span>                                            </label>
<input type="text" id="Seg" name="Seg" size="3" required placeholder="MSH" title="MSH" value="" class="fsField fsRequired" aria-required="true" />
</div>
</div>
<div id="fsRow1841988-5" class="fsRow fsFieldRow fsLastRow">
<div class="fsRowBody fsCell fsFieldCell  fsFirst fsLast fsLabelVertical  fsSpan100 " id="fsCell27920825" lang="en">
<label id="label27920825" class="fsLabel fsRequiredLabel" for="FieldNum">Field<span class="fsRequiredMarker">*</span>                                            </label>
<input type="text"  id="FieldNum" name="FieldNum" size="2" required placeholder="9" title="9" value="" class="fsField fsRequired" aria-required="true" />
</div>
</div>
<div id="fsRow1841988-6" class="fsRow fsFieldRow fsLastRow">
<div class="fsRowBody fsCell fsFieldCell  fsFirst fsLast fsLabelVertical  fsSpan100 " id="fsCell27920844" aria-describedby="fsSupporting27920844" lang="en">
<label id="label27920844" class="fsLabel" for="Channel">Channel Name                                            </label>
<input type="text" id="Channel" name="Channel" size="50" value="" class="fsField" />
<div id="fsSupporting27920844" class="fsSupporting">Optional</div>
</div>
</div>
</div>
</div>
<div id="fsSubmit1841988" class="fsSubmit fsPagination" >
<button type="button" id="fsPreviousButton1841988" class="fsPreviousButton" value="Previous Page" style="display:none; "><span class="fsFull">Previous</span><span class="fsSlim">&larr;</span></button>
<button type="button" id="fsNextButton1841988" class="fsNextButton" value="Next Page" style="display:none; "><span class="fsFull">Next</span><span class="fsSlim">&rarr;</span></button>
<input id="fsSubmitButton1841988"
class="fsSubmitButton"
style="display:block;"
type="submit"
value="Submit Form" />
<div class="clear"></div>
</div>
<script type="text/javascript" src="https://www.formstack.com/forms/js/3/jquery.min.js"></script>
<link href="https://www.formstack.com/forms/css/3/jquery-ui.css?20140508" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="https://www.formstack.com/forms/js/3/jquery-ui.min.js?20140508"></script>
<script type="text/javascript" src="https://www.formstack.com/forms/js/3/scripts.js?20140804"></script>
<script type="text/javascript" src="https://www.formstack.com/forms/js/3/analytics.js?20140409"></script>
<script type="text/javascript">
if(window.addEventListener) {
window.addEventListener('load', loadFormstack, false);
} else if(window.attachEvent) {
window.attachEvent('onload', loadFormstack);
} else {
loadFormstack();
}
function loadFormstack() {
var form1841988 = new Formstack.Form(1841988, 'https://www.formstack.com/forms/');
form1841988.logicFields = [];
form1841988.calcFields = [];
form1841988.init();
form1841988.plugins.analytics = new Formstack.Analytics('', 1841988, form1841988);
form1841988.plugins.analytics.trackTouch();
form1841988.plugins.analytics.trackBottleneck();
window.form1841988 = form1841988;
};
</script>
</form>
</body>
</html>]]