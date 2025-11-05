// Initialize New Relic before any other imports
// Must be the very first require/import
require('newrelic');

// Initialize Datadog tracer before any other imports
// DD_TRACE_DEBUG=true enables native debug logging from dd-trace
import tracer from 'dd-trace';

// Configure agentless mode: send traces directly to Datadog
// This prevents ECONNREFUSED errors when no local agent is running
const tracerConfig: any = {
  logInjection: true,
  runtimeMetrics: true,
  profiling: true,
  startupLogs: true,
  env: process.env.DD_ENV || 'development',
  service: process.env.DD_SERVICE || 'nest-datadog-poc',
  version: process.env.DD_VERSION || '1.0.0',
  // Native debug logging - controlled by DD_TRACE_DEBUG env var
  logLevel: process.env.DD_TRACE_DEBUG === 'true' ? 'debug' : 'error',
};

// Auto-detect agentless mode: if DD_SITE is set, use agentless URL
// Format: https://trace.agent.{DD_SITE}
if (process.env.DD_TRACE_AGENT_URL) {
  tracerConfig.url = process.env.DD_TRACE_AGENT_URL;
} else if (process.env.DD_SITE) {
  // Auto-generate agentless URL from DD_SITE
  tracerConfig.url = `https://trace.agent.${process.env.DD_SITE}`;
}

tracer.init(tracerConfig);

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
  logger.log('New Relic APM enabled', 'Bootstrap');
}
bootstrap();
