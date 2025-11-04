import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('health')
  getHealth(): { status: string; timestamp: string } {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('info')
  getInfo(): { message: string; version: string } {
    return {
      message: 'NestJS API with Docker and NVM',
      version: '1.0.0',
    };
  }
}
