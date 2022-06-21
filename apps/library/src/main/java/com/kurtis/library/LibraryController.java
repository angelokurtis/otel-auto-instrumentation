package com.kurtis.library;

import com.github.javafaker.Faker;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/api")
public class LibraryController {

    private final Faker faker;

    @RequestMapping(value = "/books", method = RequestMethod.GET)
    public List<Book> readBooks() {
        com.github.javafaker.Book fakeBook = this.faker.book();
        return List.of(Book.builder()
                .title(fakeBook.title())
                .author(fakeBook.author())
                .publisher(fakeBook.publisher())
                .genre(fakeBook.genre())
                .build());
    }
}
