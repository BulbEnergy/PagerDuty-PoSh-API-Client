#TODO: Update Documentation

function Get-NotificationRule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The PagerDuty ID of the user whose notification rule you would like to retrieve.
        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [string]$UserId,

        #The PagerDuty ID of a specific notification rule you would like to retrieve.
        [Parameter(Mandatory=$false, ParameterSetName='Id')]
        [string]$NotificationRuleId,

        #A PagerDuty object representing a notification rule.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyNotificationRule
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyNotificationRule, "PagerDuty.NotificationRule")
        $UserId = $PagerDutyNotificationRule.contact_method.user_id
        $NotificationRuleId = $PagerDutyNotificationRule.id
        $PagerDutyCore.VerifyNotNull($NotificationRuleId)
    }

    $PagerDutyCore.VerifyNotNull($UserId)

    $Uri = "users/$UserId/notification_rules"

    if ($NotificationRuleId -ne $null) {
        $Uri += "/$NotificationRuleId"
    }

    if ($PsCmdlet.ShouldProcess($UserId)) {
        $Result = $PagerDutyCore.ApiGet($Uri)

        if ($Result.notification_rule -ne $Null) {
            $Result.notification_rule.Insert(0,'PagerDuty.NotificationRule')
            return $Result
        } else {
            $Results = New-Object System.Collections.ArrayList
            $Results.AddRange($_.notification_rules)
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.NotificationRule')}
            return $Results
        }
    }
}

function Set-NotificationRule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The PagerDuty ID of the user whose notification rule you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [string]$UserId,

        #The PagerDuty ID of a specific notification rule you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [string]$NotificationRuleId,

        #A PagerDuty object representing a notification rule you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyNotificationRule,

        #Number of minutes it will take for the notification rule to be activated (from the time the incident is assigned to the owning user) and an alert be fired.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [int]$StartDelayInMinutes,

        #The id of the contact method
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [string]$ContactMethodId
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyNotificationRule, "PagerDuty.NotificationRule")
        $UserId = $PagerDutyNotificationRule.contact_method.user_id
        $NotificationRuleId = $PagerDutyNotificationRule.id
    }

    $PagerDutyCore.VerifyNotNull($UserId)
    $PagerDutyCore.VerifyNotNull($NotificationRuleId)

    $Uri = "users/$UserId/notification_rules/$NotificationRuleId"

    $Body = @{}

    if ($StartDelayInMinutes -ne $Null) {
        $Body["start_delay_in_minutes"] = $StartDelayInMinutes.ToString()
    }

    if ($ContactMethodId -ne $Null) {
        $Body["contact_method_id"] = $ContactMethodId
    }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the notification rule." }

    if ($PsCmdlet.ShouldProcess($Id)) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.notification_rule.Insert(0,'PagerDuty.NotificationRule')
        return $Result.user
    }
}

function New-NotificationRule {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The PagerDuty ID of the user for whom you'd like to create a notification rule.
        [Parameter(Mandatory=$true)]
        [string]$UserId,

        #Number of minutes it will take for the notification rule to be activated (from the time the incident is assigned to the owning user) and an alert be fired.
        [Parameter(Mandatory=$true)]
        [int]$StartDelayInMinutes,

        #The id of the contact method
        [Parameter(Mandatory=$true)]
        [string]$ContactMethodId
    )

    $Uri = "users/$UserId/notification_rules"

    $Body = @{}
    $Body["start_delay_in_minutes"] = $StartDelayInMinutes.ToString()
    $Body["contact_method_id"] = $ContactMethodId

    if ($PsCmdlet.ShouldProcess($Id)) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.notification_rule.Insert(0,'PagerDuty.NotificationRule')
        return $Result.user
    }
}

function Remove-NotificationRule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param(
        #The PagerDuty ID of the user you would like to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [string]$UserId,

        #The PagerDuty ID of the notification rule you would like to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [string]$NotificationRuleId,

        #A PagerDuty object representing a notification rule to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyNotificationRule
    )
        
    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyNotificationRule, "PagerDuty.NotificationRule")
        $UserId = $PagerDutyNotificationRule.contact_method.user_id
        $NotificationRuleId = $PagerDutyNotificationRule.id
    }

    $PagerDutyCore.VerifyNotNull($UserId)
    $PagerDutyCore.VerifyNotNull($NotificationRuleId)

    if ($pscmdlet.ShouldProcess($Name)) {

        $Result = $PagerDutyCore.ApiDelete("users/$UserId/notification_rules/$NotificationRuleId")
        
        if ($Result -ne $null) {
            #No Result Expected
            return $Result.user
        }
    }
}