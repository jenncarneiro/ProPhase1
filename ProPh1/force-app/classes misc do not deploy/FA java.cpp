if(OppOverridePrice==""){(SubI+GSubtotal+CSubtotal+MSubtotal+ASubtotal+ColSubtotal+UniSubtotal).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(OppOverridePrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};




if(UniBase>0){(UniBase+UniAdd).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{UniBase.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}


if(IPrice=="I"){IndPrice}else{if(IPrice=="S"){StdPrice}else{if(IPrice=="J"){JobMPrice}else{0}}}

if(IPrice=="I"){(IndPrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{if(IPrice=="S"){(StdPrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{if(IPrice=="J"){(JobMPrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{0}}};



if(GPlan>0){GBase+GPlan}else{GBase}


if(GPlan>0){(GBase+GPlan).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(GBase).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};


if(CPlan>0){CBase+CPlan}else{CBase}


if(CPlan>0){(CBase+CPlan).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(CBase).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};



if(Plan=="Municipal"){MBase}else{0}

if(Plan=="Municipal"){MBase.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{0}

if(Plan=="Community\u0020Agency"){ABase}else{0}


if(ColBase>0){(ColBase+ColAdd).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{ColBase.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}


if(IPrice=="I"){IndPrice}else{0}


(Programs>0&&Programs<=150?200:(Programs>=151&&Programs<=2500?400:(Programs>=2501&&Programs<=15000?1000:(Programs>=15001&&Programs<=35000?2000:(Programs>=35001?4000:0))))).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,");

if(Plan=="Community\u0020Agency"){ABase}else{0}

if(EPlan=="Col"){298.00}

{ColPrice.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}


@CONCATENATE("Contact Information Provided: ",@CHAR(10),"Account Contact: ",%%tfa_7%%," ",%%tfa_8%%," - ",%%tfa_14%%,@CHAR(10),"Senior Contact: ",%%tfa_37%%," ",%%tfa_38%%," - ",%%tfa_41%%,@CHAR(10),"Finance Contact: ",%%tfa_60%%," ",%%tfa_61%%," - ",%%tfa_65%%,@IF(@NOT(@ISBLANK(%%tfa_624%%)),"Faculty / Program: ",''"),@IF(@NOT(@ISBLANK(%%tfa_624%%)),%%tfa_624%%,""))
original:


if(OppOverridePrice==""){(SubI+GSubtotal+CSubtotal+MSubtotal+ASubtotal+ColSubtotal+UniSubtotal).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(OppOverridePrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};



Modified:
if(PriceOverride=="0"){(SubI+GSubtotal+CSubtotal+MSubtotal+ASubtotal+ColSubtotal+UniSubtotal).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(OppOverridePrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};








"https://prontario.tfaforms.net/" + 
$CustomMetadata.FormAssemblyForm__mdt.PRO_Membership_Form.Form_Number__c + 
IF(
    NOT(ISBLANK(Current_Active_PRO_Membership_ID__c)),
    IF(IsPersonAccount, "?indms=", "?orgms=") & Current_Active_PRO_Membership_ID__c,
    IF(IsPersonAccount, "?indid=", "?orgid=") & Id
)
+
/*plans*/
IF(
ISBLANK(TEXT(PRO_Prefill_Plan__c)),"No Prefill Plan Selected",

/* Individual Plan */

IF(TEXT( PRO_Prefill_Plan__c )="Individual","&tfa_67=tfa_68&tfa_79=Individual", "")

/*  Community Agency               IF(TEXT( PRO_Prefill_Plan__c )="", , )    */
+

IF(TEXT( PRO_Prefill_Plan__c )="Community Agency","&tfa_79=Community%20Agency","" )

/*   Education  */
+
  IF(OR(TEXT( PRO_Prefill_Plan__c )="College", TEXT(PRO_Prefill_Plan__c )="University") ,"&tfa_79=Education" ,"" )
+
IF(TEXT( PRO_Prefill_Plan__c )="College","&tfa_271=tfa_272", "")
+
IF(TEXT( PRO_Prefill_Plan__c )="University","&tfa_271=tfa_273", "")

/* Corporate, Group, Municipal */
+


IF(OR(TEXT( PRO_Prefill_Plan__c )="Corporate",TEXT( PRO_Prefill_Plan__c )="Group",TEXT( PRO_Prefill_Plan__c )="Municipal"),"&tfa_79="+TEXT( PRO_Prefill_Plan__c ),"")

/*   Type     */
+
IF(TEXT( PRO_Prefill_Plan__c )="Individual","&tfa_2=Individual","&tfa_2=Organization")



)


original
Override!=0?Override:Fee.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,");






if(PriceOverride=="0"){(SubI+GSubtotal+CSubtotal+MSubtotal+ASubtotal+ColSubtotal+UniSubtotal).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{(OppOverridePrice).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};





if PriceOverride is True, use override else use fee

if(PriceOverride==1){Override.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}else{Fee.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")};


@CONCATENATE("Contact Information Provided:",@CHAR(10),"Account Contact: ",%%tfa_3%%," ",%%tfa_105%%," - ",%%tfa_4%%,@CHAR(10),"Senior Contact: ",%%tfa_5%%," ",%%tfa_110%%," - ",%%tfa_6%%,@CHAR(10),"Finance Contact: ",%%tfa_91%%," ",%%tfa_119%%," - ",%%tfa_122%%,@IF(@NOT(@ISBLANK(%%tfa_321%%)),"Legal Entity Name: ","")),@IF(@NOT(@ISBLANK(%%tfa_321%%)),%%tfa_321%%,""))