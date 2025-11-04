// Initialize Datadog tracer before any other imports
// DD_TRACE_DEBUG=true enables native debug logging from dd-trace
import tracer from 'dd-trace';

// Use agentless mode if DD_TRACE_AGENT_URL is set, otherwise use local agent
const agentUrl = process.env.DD_TRACE_AGENT_URL;

tracer.init({
  logInjection: true,
  runtimeMetrics: true,
  profiling: true,
  startupLogs: true,
  env: process.env.DD_ENV || 'development',
  service: process.env.DD_SERVICE || 'nest-datadog-poc',
  version: process.env.DD_VERSION || '1.0.0',
  // Native debug logging - controlled by DD_TRACE_DEBUG env var
  logLevel: process.env.DD_TRACE_DEBUG === 'true' ? 'debug' : 'error',
  // Configure URL for agentless mode (sends directly to Datadog)
  // If not set, defaults to local agent at 127.0.0.1:8126
  ...(agentUrl && { url: agentUrl }),
});

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { LoggerService } from './logger/logger.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });

  const logger = app.get(LoggerService);
  app.useLogger(logger);

  await app.listen(3000);
  logger.log('Application is running on: http://localhost:3000', 'Bootstrap');
  logger.log(
    'Datadog APM enabled - use DD_TRACE_DEBUG=true to see trace events',
    'Bootstrap',
  );
}
bootstrap();
