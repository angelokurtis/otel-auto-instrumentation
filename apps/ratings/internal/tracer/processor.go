package tracer

import (
	"context"
	"fmt"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/trace"
	"time"
)

//const endpoint = "localhost:4318"
//const endpoint = "otelcol-qa.observability.ppay.me"
const endpoint = "otelcol.lvh.me"

func newProcessor(ctx context.Context) (trace.SpanProcessor, error) {
	ctx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()
	exporter, err := otlptracehttp.New(ctx,
		otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint(endpoint),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection to collector: %w", err)
	}
	return trace.NewBatchSpanProcessor(exporter), nil
}
