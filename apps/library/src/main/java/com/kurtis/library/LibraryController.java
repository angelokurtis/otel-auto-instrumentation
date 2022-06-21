package com.kurtis.library;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class LibraryController {
    @RequestMapping(value = "/books", method = RequestMethod.GET)
    public List<Book> readBooks() {

        return List.of(new Book());
    }
}
