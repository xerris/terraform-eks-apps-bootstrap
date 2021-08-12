variable "service_values"{
    type = map(object(
    {
        service_name  = string
        lb_type = string
        internal   = bool
    }
  ))
}