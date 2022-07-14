package com.kurtis.library;

import com.github.javafaker.Faker;
import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Log4j2
@AllArgsConstructor
@RestController
@RequestMapping("/api")
public class LibraryController {

    private final Faker faker;

    @RequestMapping(value = "/books", method = RequestMethod.GET)
    public List<Book> readBooks() {
        Random random = new Random();
        int max = 5;
        int min = 2;
        max = random.nextInt(max - min) + min;
        log.info("Found {} books", max);
        return IntStream.range(0, max)
                .mapToObj(operand -> this.faker.book())
                .map(fakeBook -> Book.builder()
                        .title(fakeBook.title())
                        .author(fakeBook.author())
                        .publisher(fakeBook.publisher())
                        .genre(fakeBook.genre())
                        .build())
                .collect(Collectors.toList());
    }
}
