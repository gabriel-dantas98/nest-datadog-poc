// Initialize Datadog tracer before any other imports
import tracer from 'dd-trace';

tracer.init({
  logInjection: true,
  runtimeMetrics: true,
  profiling: true,
  env: process.env.DD_ENV || 'development',
  service: process.env.DD_SERVICE || 'nest-datadog-poc',
  version: process.env.DD_VERSION || '1.0.0',
});

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
  console.log('Application is running on: http://localhost:3000');
  console.log('Datadog APM enabled');
}
bootstrap();
