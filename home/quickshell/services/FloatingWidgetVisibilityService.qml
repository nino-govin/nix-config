pragma Singleton

import Quickshell

Singleton {
    function activeWorkspace(outputName: string): var {
        if (!HyprlandService.available || !HyprlandService.windowsReady || !outputName)
            return null;

        return HyprlandService.workspaces.find(workspace =>
            workspace.output === outputName && workspace.is_active) || null;
    }

    function visibleOnOutput(outputName: string): bool {
        if (SettingsService.floatingWidgetVisibilityMode === "hidden")
            return false;
        if (SettingsService.floatingWidgetVisibilityMode === "always")
            return true;

        const workspace = activeWorkspace(outputName);
        if (!workspace)
            return false;

        return !HyprlandService.windows.some(window =>
            window.workspace_id === workspace.id);
    }
}
