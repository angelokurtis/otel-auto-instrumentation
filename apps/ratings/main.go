package main

import (
	"context"
	"fmt"
	"github.com/angelokurtis/otel-auto-instrumentation/apps/ratings/internal/tracer"
	"github.com/go-logr/stdr"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
	"log"
	"time"
)

func main() {
	// Set logging level to info to see SDK status messages
	stdr.SetVerbosity(5)

	ctx := context.Background()
	_, shutdown, err := tracer.NewProvider(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := shutdown(ctx); err != nil {
			log.Fatal("failed to shutdown TracerProvider: %w", err)
		}
	}()
	testTracer := otel.Tracer("test-tracer")
	commonAttrs := []attribute.KeyValue{
		attribute.String("attrA", "chocolate"),
		attribute.String("attrB", "raspberry"),
		attribute.String("attrC", "vanilla"),
	}
	ctx, span := testTracer.Start(ctx, "CollectorExporter-Example", trace.WithAttributes(commonAttrs...))
	defer span.End()
	total := 10
	for i := 0; i < total; i++ {
		_, iSpan := testTracer.Start(ctx, fmt.Sprintf("Sample-%d", i))
		log.Printf("Doing really hard work (%d / %d)\n", i+1, total)

		<-time.After(time.Second)
		iSpan.End()
	}

	log.Printf("Done!")
}
