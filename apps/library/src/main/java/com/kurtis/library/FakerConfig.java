package com.kurtis.library;

import com.github.javafaker.Faker;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Locale;

@Configuration
public class FakerConfig {

    @Bean
    public Faker buildFaker() {
        return new Faker(Locale.ENGLISH);
    }
}
