variable "NSGRuleName" {
    description = "name of the NSG rule"
}

variable "NSGRulePriority" {
    description = "Priority of the rule"
}

variable "NSGRuleDirection" {
    description = "Direction of the rule"
}

variable "NSGRuleAccess" {
    description = "access to NSG rule"
}

variable "NSGRuleProtocol" {
  description = "Protocol of rule"
}

variable "NSGRuleSourcePortRange" {
  description = "source port of rule"
}

variable "NSGRuleDestinationPortRanges" {
  description = "NSG Rule destination port range"
  type = list
}

variable "NSGRuleSourceAddressPrefixes" {
  description = "Source address prefixes for rule"
  type = list
}

variable "RGName" {
    description = "Resource group name"
}

variable "NSGReference" {
    description = "Network Security group to associate the rule with"

}

variable "NSGRuleDestinationAddressPrefix" {
    type = string
    default = "*"
}
