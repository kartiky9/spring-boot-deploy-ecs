package com.springdeployecs.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {

    @GetMapping("/hello/{name}")
    @ResponseBody
    public String hello(@PathVariable(value = "name") String name) {
        return "Hello " + name;
    }
}
