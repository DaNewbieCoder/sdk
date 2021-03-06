/*
 *  Copyright (c) 2009-2010 jMonkeyEngine
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 * 
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 
 *  * Neither the name of 'jMonkeyEngine' nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 * 
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 *  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.jme3.gde.codepalette.scene;
import com.jme3.gde.codepalette.JmePaletteUtilities;
import javax.swing.text.BadLocationException;
import javax.swing.text.JTextComponent;
import org.openide.text.ActiveEditorDrop;

/**
 *
 * @author normenhansen, zathras
 */
public class JmePaletteAppSettings implements ActiveEditorDrop {

    public JmePaletteAppSettings() {
    }

    private String createBody() {

        String body = "Main app = new Main();\nAppSettings cfg = new AppSettings(true);\ncfg.setFrameRate(60); // set to less than or equal screen refresh rate\ncfg.setVSync(true);   // prevents page tearing\ncfg.setFrequency(60); // set to screen refresh rate\ncfg.setResolution(1024, 768);   \ncfg.setFullscreen(true); \ncfg.setSamples(2);    // anti-aliasing\ncfg.setTitle(\"My jMonkeyEngine 3 Game\"); // branding: window name\ntry {\n  // Branding: window icon\n  cfg.setIcons(new BufferedImage[]{ImageIO.read(new File(\"assets/Interface/icon.gif\"))});\n} catch (IOException ex) {\n  Logger.getLogger(Main.class.getName()).log(Level.SEVERE, \"Icon missing.\", ex);\n}\n// branding: load splashscreen from assets\ncfg.setSettingsDialogImage(\"Interface/MySplashscreen.png\"); \n//app.setShowSettings(false); // or don't display splashscreen\napp.setSettings(cfg);\napp.start();";
        return body;
    }

    public boolean handleTransfer(JTextComponent targetComponent) {
        String body = createBody();
        try {
            JmePaletteUtilities.insert(body, targetComponent);
        } catch (BadLocationException ble) {
            return false;
        }
        return true;
    }

}
