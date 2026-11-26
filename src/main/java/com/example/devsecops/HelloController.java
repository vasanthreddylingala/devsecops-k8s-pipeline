package com.example.devsecops;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String home() {
        return "DevSecOps pipeline demo is running";
    }

    @GetMapping("/api/hello")
    public Map<String, String> hello(@RequestParam(defaultValue = "World") String name) {
        return Map.of("message", "Hello, " + name + "!", "version", "1.0.0");
    }
}
