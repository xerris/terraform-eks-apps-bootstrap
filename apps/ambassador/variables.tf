variable "service_values"{
    type = map(object(
    {
        service_name  = string
        lb_type = string
        internal   = bool
        ports = map(object(
          {
            name = string
            port = number
            protocol = string
            target_port = number
        }
        ))
    }
  ))
}