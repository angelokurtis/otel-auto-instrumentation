package tracer

import (
	"context"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

func NewProvider(ctx context.Context) (trace.TracerProvider, func(context.Context) error, error) {
	res, err := newResource(ctx)
	if err != nil {
		return nil, nil, err
	}
	processor, err := newProcessor(ctx)
	if err != nil {
		return nil, nil, err
	}
	provider := sdktrace.NewTracerProvider(
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
		sdktrace.WithResource(res),
		sdktrace.WithSpanProcessor(processor),
	)
	otel.SetTracerProvider(provider)
	otel.SetTextMapPropagator(propagation.TraceContext{})
	return provider, provider.Shutdown, nil
}
