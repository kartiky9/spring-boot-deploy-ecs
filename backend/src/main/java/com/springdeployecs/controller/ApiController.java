package com.springdeployecs.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {

    @Value("${version.hardcoded}")
    private String versionFromProps;

    @Value("${version.secrets}")
    private String versionFromSecrets;

    @GetMapping("/hello/{name}")
    @ResponseBody
    public String hello(@PathVariable(value = "name") String name) {
        return "Hello " + name;
    }

    @GetMapping("/version")
    @ResponseBody
    public Map<String, String> version() {
        var hm = new HashMap<String, String>();

        hm.put("versionFromProps", versionFromProps);
        hm.put("versionFromSecrets", versionFromSecrets);

        return hm;
    }

}
