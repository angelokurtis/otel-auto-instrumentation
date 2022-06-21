package com.kurtis.library;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Book {
    private String author;
    private String title;
    private String publisher;
    private String genre;
}
