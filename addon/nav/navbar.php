<?php
$current_page = basename($_SERVER['PHP_SELF']);
?>



<div class="d-flex justify-content-center align-items-center" style="height: 50px;">
    <ul class="list-unstyled mb-0">
        <li style="color: blue; font-size: 18px;"><?php echo $Manifest->{'name'} . " V " . $Manifest->{'version'}; ?></li>
    </ul>
</div>

    </ul>
</nav>


<style>
.bullet {
    font-size: 12px;
    color: #999;
    margin-left: 6px;
}
</style>


<style>
.menu-horizontal {
    text-align: center; 
    margin-top: 10px;
}

.menu-horizontal ul {
    display: inline-flex;   
    list-style: none;      
    padding: 0;
    margin: 0;
    gap: 20px;             
}

.menu-horizontal li a {
    text-decoration: none;
    color: #333;
    font-size: 16px;
}

.menu-horizontal li a.active {
    font-weight: bold;
    border-bottom: 2px solid #0d6efd;
    color: #0d6efd;
}
</style>


<div class="menu-horizontal">
    <ul>
        <li>
            <a href="index.php" class="<?= ($current_page == 'index.php') ? 'active' : '' ?>">
                <i class="bi bi-receipt-cutoff" style="color: #0d6efd;"></i> Dici Mensal
        </li>
        <li>
            <a href="trimestral.php" class="<?= ($current_page == 'trimestral.php') ? 'active' : '' ?>">
                <i class="bi bi-receipt-cutoff" style="color: #25d366;"></i> PPP Trimestral
            </a>
            </li>
        <li>
            <a href="demo.php" class="<?= ($current_page == 'demo.php') ? 'active' : '' ?>">
                <i class="fa fa-puzzle-piece" style="color: #c21a4cff;"></i> Conheça outros Addon
            </a>
        </li>
    </ul>
</div>
