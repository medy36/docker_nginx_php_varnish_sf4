vcl 4.0;

import std;

backend default {
  # use your nginx container ip or hostname
  .host = "nginx";
  .port = "8080";
  # Health check
  #.probe = {
  #  .url = "/";
  #  .timeout = 5s;
  #  .interval = 10s;
  #  .window = 5;
  #  .threshold = 3;
  #}
}

// this bloc is called after receiving a request
// we define the use of ESI headers
sub vcl_recv {
      set req.http.Surrogate-Capability = "abc=ESI/1.0";
}

// this bloc is after receiving the headers reponse
// we delete the header and activate ESI
sub vcl_backend_response {
      if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
               unset beresp.http.Surrogate-Control;
               set beresp.do_esi = true;
      }
}

//# Hosts allowed to send BAN requests
//acl ban {
//  "localhost";
//  "php";
//}
//
//sub vcl_backend_response {
//  # Ban lurker friendly header
//  set beresp.http.url = bereq.url;
//
//  # Add a grace in case the backend is down
//  set beresp.grace = 1h;
//}
//
//sub vcl_deliver {
//  # Don't send cache tags related headers to the client
//  unset resp.http.url;
//  # Uncomment the following line to NOT send the "Cache-Tags" header to the client (prevent using CloudFlare cache tags)
//  #unset resp.http.Cache-Tags;
//}
//
//sub vcl_recv {
//  # Remove the "Forwarded" HTTP header if exists (security)
//  unset req.http.forwarded;
//
//  # Ban by cache tags
//  if (req.method == "BAN") {
//    if (client.ip !~ ban) {
//      return(synth(405, "Not allowed"));
//    }
//
//    if (req.http.ApiPlatform-Ban-Regex) {
//      ban("obj.http.Cache-Tags ~ " + req.http.ApiPlatform-Ban-Regex);
//
//      return(synth(200, "Ban added"));
//    }
//
//    return(synth(400, "ApiPlatform-Ban-Regex HTTP header must be set."));
//  }
//}
//
//sub vcl_hit {
//  if (obj.ttl >= 0s) {
//    # A pure unadulterated hit, deliver it
//    return (deliver);
//  }
//  if (std.healthy(req.backend_hint)) {
//    # The backend is healthy
//    # Fetch the object from the backend
//    return (miss);
//  }
//  # No fresh object and the backend is not healthy
//  if (obj.ttl + obj.grace > 0s) {
//    # Deliver graced object
//    # Automatically triggers a background fetch
//    return (deliver);
//  }
//  # No valid object to deliver
//  # No healthy backend to handle request
//  # Return error
//  return (synth(503, "API is down"));
//}
