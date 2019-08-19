import { WebPlugin } from '@capacitor/core';
import { DownloadPlugin } from './definitions';

export class DownloadWeb extends WebPlugin implements DownloadPlugin {
  constructor() {
    super({
      name: 'Download',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const Download = new DownloadWeb();

export { Download };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(Download);
